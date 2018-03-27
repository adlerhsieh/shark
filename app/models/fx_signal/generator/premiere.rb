class FxSignal::Generator::Premiere < FxSignal::Generator::Base

  def initialize(message_id)
    @message_id = message_id
    @document = Timeout::timeout(40) { service.message(message_id) }
  end

  def data
    @data ||= (
      @document.payload.try(:parts).try(:first).try(:body).try(:data) || 
      @document.payload.try(:body).try(:data)
    )
  end

  def process!
    first_part = data.split("****").first
    elements = Nokogiri::HTML.parse(first_part).xpath("//div").select do |s| 
      s.children.first.is_a?(Nokogiri::XML::Text) && s.text.match(/(BUY|SELL)/)
    end

    elements.each do |element|
      text = element.text
      direction = text.match(/(BUY|SELL)/).to_s
      pairs = text.match(/#{direction}[ ]?([\S]{6,8})/).try(:[], 1)

      next if direction.blank? || pairs.blank?

      pair = Pair.find_by(
        base: pairs[0..2],
        quote: pairs[3..5],
        mini: true
      )

      next if pair.blank?

      entry = text.match(/@[ ]?(\d{1,5}\.\d{1,5})/).try(:[], 1)
      tp = text.match(/TP[ ]?(\d{1,5}\.\d{1,5})/).try(:[], 1)
      sl = direction == "BUY" ? entry.to_f - pair.pip(30) : entry.to_f + pair.pip(30)

      next if entry.blank? || tp.blank?

      signal = FxSignal.create!(
        # from parsing
        direction: direction.downcase,
        pair: pair,
        entry: entry,
        take_profit: tp,
        stop_loss: sl,
        # custom
        source_secondary_id: @message_id,
        expired_at: Time.current + 1.day,
        source: Source.find_or_create_by(name: "fxpremiere.com") { |s| s.active = true }
      )

      if signal.entry == 0.0 ||
          signal.take_profit == 0.0 ||
          signal.stop_loss == 0.0
        signal.update(expired_at: nil)
        next
      end

      order = signal.create_order
      order.ig_place_order
    end
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

