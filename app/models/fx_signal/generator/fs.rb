class FxSignal::Generator::Fs < FxSignal::Generator::Base

  def initialize(message_id)
    @message_id = message_id
    @document = Timeout::timeout(40) { service.message(message_id) }
  end

  def process!
    # log.write("Processing #{@message_id}")

    if expired?
      # log.write("Skipped: Signal is older than 24 hours.")
      return
    end

    attrs = {
      source_secondary_id: @message_id,
      expired_at: Time.current + 7.days
    }
    data    = @document.payload.parts.first.body.data
    parts = data.match(/\r\n(.*)\r\n.*(SHORT|LONG)[ ]?(\S{6,12})[ ]?@[ ]?(\d{0,5}\.\d{0,5})/i)
    username = parts[1].squish
    attrs[:source] = Source.find_or_create_by(name: "forexsignals.com", username: username) do |source|
      source.active = true
    end

    attrs[:direction] = parts[2].to_s.downcase
    case attrs[:direction]
    when "long"
      attrs[:direction] = "buy"
    when "short"
      attrs[:direction] = "sell"
    end

    attrs[:pair] = Pair.find_by(
      base: parts[3][0..2],
      quote: parts[3][3..5],
      mini: true
    )
    attrs[:entry] = parts[4].to_f
    attrs[:take_profit] = data.match(/take profit: (\d{0,5}\.\d{0,5})/i)[1].to_f
    attrs[:stop_loss] = data.match(/stop loss: (\d{0,5}\.\d{0,5})/i)[1].to_f

    if attrs[:direction].blank? ||
        attrs[:pair].blank? ||
        attrs[:entry].blank?
      return
    end

    signal = FxSignal.create!(attrs)

    if signal.entry == 0.0 ||
        signal.take_profit == 0.0 ||
        signal.stop_loss == 0.0
      signal.update(expired_at: nil)
      return
    end

    order = signal.create_order
    order.ig_place_order
  rescue => ex
    Raven.capture_exception(ex, extra: { 
      message_id: @message_id,
      data: data
    })
  end

  private

    def service
      @service ||= Gmail::Service.new
    end

end
