module Crawler
  class LiveForexSignals < Crawler::Base

    HOST = "https://live-forex-signals.com"

    attr_reader :document

    def initialize
      @document = get_document("#{HOST}/en")
      @log = AuditLog.new(event: self.class)
    end

    def parse!
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
            signal.opened_at = time_slot
            if (ds = duplicate_signal(signal))
              return @log.push("Probably a duplicate of signal ##{ds.id}. Skipped")
            end
          end

          # Bought at
          if item.text.include?("Bought at")
            encrypted_value = item.css(".signal-value").text.remove("\t", "f('", "')", ";")
            puts encrypted_value
            signal.entry = decode_function.call(encrypted_value)
          end

        end

        puts signal.attributes
      end
      
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
      puts char_list
      if char_list.blank?
        raise "Char list in decode function might be altered."
      end

      offset = raw_function.match(/zi=(.)*;/).to_s.remove("zi=", ";")
      puts offset
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
