class FxSignal::Generator::Premiere < FxSignal::Generator::Base

  def initialize(message_id)
    @message_id = message_id
    @document = Timeout.timeout(40) { service.message(message_id) }
  end

  def process!
    signals_data = FxSignal::Parser::Premiere.new(@message_id, data).parse

    signals_data.each do |signal_attrs|
      error = signal_attrs.delete(:error)
      signal = FxSignal.create!(signal_attrs)

      next if error

      signal.source.strategies.each do |strategy|
        strategy.create_ig_order_from(signal)
      end
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

