class FxSignal::Generator::Premiere < FxSignal::Generator::Base

  def initialize(message_id)
    @message_id = message_id
    @document = Timeout::timeout(40) { service.message(message_id) }
  end

  def process!
    signals = FxSignal::Parser::Premiere.new(@message_id, data).parse

    signals.each do |signal_data|
      error = signal_data.delete(:error)
      signal = FxSignal.create!(signal_data)

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

