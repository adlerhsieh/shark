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

    parsed_data = data.split("Risk Warning").first.gsub("\r", "").gsub("\t", "").gsub("\n", "===")

    # The following will get:
    #
    # [["EURCHF", "Buy", "1.1750", "1.1725"],
    #  ["GBPCHF", "Buy", "1.3420", "1.3370"],
    #  ["GBPJPY", "Sell", "150.80", "151.30"],
    #  ["AUDJPY", "Sell", "81.80", "82.10"],
    #  ["EURSEK", "Buy", "10.1500", "10.1200"]]
    parsed_data.scan(/([A-Z]{6,8})[ ]?-[ ]?We look to (Buy|Sell) at (\d{1,5}\.\d{1,5}) \(stop at (\d{1,5}\.\d{1,5})\)/i).each do |item|
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
      
      signal = FxSignal.create!(
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
        expired_at: Time.current + 1.day,
        terminated_at: terminated_at,
        source: Source.find_or_create_by(name: "PIA First") { |s| s.active = true }
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

    # http://www.pia-first.co.uk/analysis
    def terminated_at
      t = Time.current + 1.day
      if data.downcase.include?("asian/pacific currencies")
        Time.new(t.year, t.month, t.day, 16, 0, 0)
      else
        Time.new(t.year, t.month, t.day, 21, 0, 0)
      end
    end

end
