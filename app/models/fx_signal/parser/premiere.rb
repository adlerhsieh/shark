class FxSignal::Parser::Premiere < FxSignal::Parser::Base

  def initialize(message_id, data) 
    @message_id = message_id
    @data = data
  end

  def parse
    first_part = @data.split("****").first
    elements = Nokogiri::HTML.parse(first_part).xpath("//div").select do |s| 
      s.children.first.is_a?(Nokogiri::XML::Text) && s.children.first.text.match(/(BUY|SELL)/)
    end

    elements.map do |element|
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

      if entry.blank? || tp.blank?
        expired_at = nil
        error = :insufficient_info
      else
        expired_at = Time.current + 1.day
      end

      {
        # from parsing
        direction: direction.downcase,
        pair: pair,
        entry: entry,
        take_profit: tp,
        stop_loss: sl,
        target_resource: "Order",
        action: "create",
        # custom
        error: error,
        source_secondary_id: @message_id,
        expired_at: expired_at,
        source: Source.find_or_create_by(name: "fxpremiere.com") { |s| s.active = true }
      }
    end.compact
  end
end
