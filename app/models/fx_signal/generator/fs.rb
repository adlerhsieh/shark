class FxSignal::Generator::Fs < FxSignal::Generator::Base

  def initialize(message_id)
    @message_id = message_id
    @document = Timeout::timeout(40) { service.message(message_id) }
  end

  def process!
    attrs = FxSignal::Parser::Fs.new(@message_id, data).parse

    error = attrs.delete(:error)

    signal = FxSignal.create!(attrs)

    return if error

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
