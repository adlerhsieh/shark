class FxSignal::Generator::Pia < FxSignal::Generator::Base

  def initialize(message_id)
    @message_id = message_id
    @document = Timeout::timeout(40) { service.message(message_id) }
  end

  def process!
    if data.match(/update - \S{6,8} - /i)
      FxSignal::Updater::Pia.new(@message_id).process!
      return
    end

    return if [
      "fx majors",
      "fx crosses",
      "asian/pacific currencies"
    ].all? { |term| data.downcase.include?(term).! }

    signals_data = FxSignal::Parser::Pia.new(@message_id, data).parse

    signals_data.each do |signal_attrs|
      error = signal_attrs.delete(:error)
      signal = FxSignal.create!(signal_attrs)

      next if error

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
