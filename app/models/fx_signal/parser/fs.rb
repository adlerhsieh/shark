class FxSignal::Parser::Fs < FxSignal::Parser::Base

  def initialize(message_id, data) 
    @message_id = message_id
    @data = data
  end

  def parse
    attrs = {
      source_secondary_id: @message_id,
      expired_at: Time.current + 7.days,
      target_resource: "Order",
      action: "create"
    }
    parts = @data.match(/\r\n(.*)\r\n.*(SHORT|LONG)[ ]?(\S{6,12})[ ]?@[ ]?(\d{0,5}\.\d{0,5})/i)
    username = parts[1].squish
    attrs[:source] = Source.find_or_create_by(name: "forexsignals.com", username: username) do |source|
      source.active = true
    end
    if attrs[:source].sources_trading_strategies.blank?
      attrs[:source].sources_trading_strategies.create(trading_strategy_id: 2, default_strategy: true)
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
    attrs[:take_profit] = @data.match(/take profit: (\d{0,5}\.\d{0,5})/i).try(:[], 1).to_f
    attrs[:stop_loss] = @data.match(/stop loss: (\d{0,5}\.\d{0,5})/i).try(:[], 1).to_f

    if attrs[:direction].blank? ||
        attrs[:pair].blank? ||
        attrs[:entry].blank?
      attrs[:error] = :insufficient_info
    elsif attrs[:take_profit] == 0.0 ||
        attrs[:stop_loss] == 0.0
      attrs[:expired_at] = nil
      attrs[:error] = :no_tp_sl
    end

    attrs
  end

end
