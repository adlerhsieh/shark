module Crawler

  # which direction?
  # how long is the lag for opened_at and closed_at?
  # determine how to close
  #   - close as it close?
  #   - close according to IG?
  class LiveForexSignals < Crawler::Base

    HOST = "https://live-forex-signals.com"

    attr_accessor :document

    def access
      visit("/en")
      sleep(2)
      has_selector?("#signals")
      @document = Nokogiri::HTML(page.body)
    end

    def process!
      if @document.to_s.include?("Daily limit for unauthenticated use exceeded")
        log.write("Webiste warns that our unauthenticated daily limit is exceeded.")
      end

      signal_cells = @document.css(".signal-cell")
        
      signal_cells.each do |signal_cell|
        signal = FxSignal.new

        title = signal_cell.css(".col-sm-8").first.text.remove("\n", "\r", "\t")
        signal.pair_id = pair_id(title)


        signal_cell.css(".signal-item").each do |item|

          # Parse time if it's a time slot
          time_slot = nil
          if item.text.include?("shotDTgmt")
            time_string = item.text.match(/showDTgmt\(.*\)/)
            time_slot = parse_time(time_string)
          end

          # From
          if item.text.include?("From")
            log.write("Processing 'From' with time_slot: #{time_slot}")
            signal.opened_at = time_slot
            if (ds = duplicate_signal(signal))
              log.write("Probably a duplicate of signal ##{ds.id}. Skipped")
              return 
            end
          end

          # # Direction
          # if item.text.include?("Buy")
          #   signal.direction = "buy"
          # elsif item.text.include?("Sell")
          #   signal.direction = "sell"
          # end

          # Bought at
          if item.text.include?("Bought at")
            log.write("Processing 'Bought at'")
            encrypted_value = item.css(".signal-value").text.remove("\t", "f('", "')", ";")
            log.write("Encrypted value: #{encrypted_value}")
            # if the value includes both encrypted value & decrypted value, then we just remove the former.
            if encrypted_value.match(/[A-Z]*[\d\.]*/)
              log.write("Value has both encrypted & decrypted value. Use decrypted value instead.")
              signal.entry = encrypted_value.gsub(/[A-Z]*/, "")
            # or decode as it as
            else
              log.write("Processing encrypted value...")
              signal.entry = decode_function.call(encrypted_value)
            end
          end

        end # end signal-item

        signal.save!

      end # end signal-cell

      wrap_up
    end

    def pair_id(pair_string)
      base, quote = pair_string.split("/")
      raise "Expecting base currency to be present. Got: #{base} (#{base.class})" unless base.is_a?(String)
      raise "Expecting quote currency to be present. Got: #{quote} (#{quote.class})" unless quote.is_a?(String)
      Pair.find_by(base: base, quote: quote).id
    end

    def parse_time(time_string)
      units = time_string.remove("showDTgmt", "(", ")").split(",").map(&:to_i)
      DateTime.new(*units)
    end

    def duplicate_signal(signal)
      FxSignal
        .where("created_at > ?", Time.current - 1.day)
        .where(pair_id: signal.pair_id, opened_at: signal.opened_at)
        .first
    end

    def decode_function
      return @decode_function if @decode_function

      raw_function = @document.css("#signals").first.elements.first.text

      if not raw_function.include?("function f(s)")
        raise "Decode function is moved to another element"
      end

      char_list = raw_function.match(/var(.)*'(.)*';/).to_s.remove(/var (.)*= /, "'", "'", ";")
      log.write("char_list: #{char_list}")
      if char_list.blank?
        raise "Char list in decode function might be altered."
      end

      offset = raw_function.match(/zi=(.)*;/).to_s.remove("zi=", ";")
      log.write("offset: #{offset}")
      if offset.blank?
        raise "Offset in decode function might be altered."
      end

      @decode_function = -> (str) do
                            str.split("").map do |char|
                              i = char.ord - offset.to_i - str.index(char)
                              char_list[i]
                            end.join
                          end
    end

  end
end
