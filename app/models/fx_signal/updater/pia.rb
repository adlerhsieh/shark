class FxSignal::Updater::Pia < FxSignal::Updater::Base

  def initialize(message_id)
    @message_id = message_id
    @document = Timeout::timeout(40) { service.message(message_id) }
  end

  def process!
    pairs = data.match(/update - (\S{6,8}) - /i).try(:[], 1)

    return if pairs.blank?

    pair = Pair.find_by(
      base: pairs[0..2],
      quote: pairs[3..5],
      mini: true
    )

    return if pair.nil?

    attrs = {
      source_secondary_id: @message_id,
      expired_at: Time.current + 20.minutes,
      pair: pair
    }

    if (matched = data.match(/cancel (the )?trade/i))
      attrs[:target_resource] = "Order"
      attrs[:action] = "cancel"
    end

    if (matched = data.match(/tak(e|ing) (some )?profit/i))
      attrs[:target_resource] = "Position"
      attrs[:action] = "close"
    end

    if (matched = data.match(/stop to (\d{1,5}\.\d{1,5})/i))
      attrs[:stop_loss] = matched[1]
    end

    if (entry = data.match(/move to (\d{1,5}\.\d{1,5})/i)) && 
        data.match(/stop to entry/i)
      attrs[:stop_loss] = entry[1]
    end

    if (matched = data.match(/target to (\d{1,5}\.\d{1,5})/i))
      attrs[:take_profit] = matched[1]
    end

    if attrs[:target_resource].nil?
      attrs[:target_resource] = "Position"
      attrs[:action] = "update"
    end

    FxSignal.create!(attrs)
  end

  private

    def data
      @data ||= (
        @document.payload.try(:parts).try(:first).try(:body).try(:data) || 
        @document.payload.try(:body).try(:data)
      )
    end

    def service
      @service ||= Gmail::Service.new
    end

end
