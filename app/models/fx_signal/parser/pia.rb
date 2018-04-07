class FxSignal::Parser::Pia < FxSignal::Parser::Base

  def initialize(message_id, data) 
    @message_id = message_id
    @data = data
  end

  def parse
    parsed_data = @data.split("Risk Warning").first.gsub("\r", "").gsub("\t", "").gsub("\n", "===")

    # The following will get:
    #
    # [["EURCHF", "Buy", "1.1750", "1.1725"],
    #  ["GBPCHF", "Buy", "1.3420", "1.3370"],
    #  ["GBPJPY", "Sell", "150.80", "151.30"],
    #  ["AUDJPY", "Sell", "81.80", "82.10"],
    #  ["EURSEK", "Buy", "10.1500", "10.1200"]]
    parsed_data.scan(/([A-Z]{6,8})[ ]?-[ ]?we look to (buy|sell) [a-zA-Z\s]{1,20}(\d{1,5}\.\d{1,5}) \(stop at (\d{1,5}\.\d{1,5})\)/i).map do |item|
      pairs     = item[0]
      direction = item[1]
      entry     = item[2]
      sl        = item[3]

      next if pairs.nil? || direction.nil? || entry.nil? || sl.nil?

      pair = Pair.find_by(
        base: pairs[0..2],
        quote: pairs[3..5],
        mini: true
      )

      next if pair.blank?

      tp_finder = parsed_data.split(/#{pairs} -===/).last.match(/Our profit targets will be (\d{1,5}\.\d{1,5})( and \d{1,5}\.\d{1,5})?([ ]?\.?={1,6}?Confidence Level[:]?[ ]?(\d{1,3})%)?/i)
      tp = tp_finder.try(:[], 1)
      confidence = tp_finder.try(:[], 4).try(:to_f).try(:/, 100)

      if tp.blank?
        Raven.capture_message("Parser might be wrong in finding tp", extra: { 
          message_id: @message_id,
          pair: pairs,
          parsed_data: parsed_data
        })
        next
      end

      if FxSignal.where(direction: direction.downcase, pair: pair, entry: entry)
                 .where("created_at > ? AND created_at < ?", Time.current - 8.hours, Time.current + 8.hours)
                 .any?
        Blacklist::Email.gmail.find_or_create_by(source_id: @message_id)
        next
      end

      source = Source.find_or_create_by(name: "PIA First") { |s| s.active = true }
      error = nil

      if entry == 0.0 || tp == 0.0 || sl == 0.0
        expired_at = nil
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
        confidence: confidence,
        target_resource: "Order",
        action: "create",
        # custom
        source_secondary_id: @message_id,
        expired_at: expired_at,
        terminated_at: terminated_at,
        source: source,
        error: error
      }
    end.compact
  end
  
  # http://www.pia-first.co.uk/analysis
  def terminated_at
    t = Time.current + 1.day
    if @data.downcase.include?("asian/pacific currencies")
      Time.utc(t.year, t.month, t.day, 15, 0, 0)
    else
      Time.utc(t.year, t.month, t.day, 20, 0, 0)
    end
  end

end
