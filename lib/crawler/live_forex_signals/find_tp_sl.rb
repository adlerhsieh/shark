module Crawler

  class LiveForexSignals

    class FindTpSl

      attr_reader :tp, :sl, :found, :sold

      def initialize(document, pair_text)
        @document = document
        @pair_text = pair_text
      end

      def find
        cell = @document.css(".signal-cell").to_a.find { |s| s.text.include?(@pair_text)}

        if cell.blank?
          @found = false
          return self
        end

        sold_cell = cell.css(".row").to_a.find { |s| s.text.downcase.include?("sold at") }
        if sold_cell.present?
          @found = false
          @sold = true
          return self
        end

        entry_cell = cell.css(".row").to_a.find { |s| s.text.downcase.match(/(buy|sell) at/) }
        if entry_cell.blank?
          @found = false
          return self
        end
        @entry = entry_cell.css(".signal-price").text.match(/\d*\.\d*/).to_s.to_f

        tp_cell = cell.css(".row").to_a.find { |s| s.text.downcase.include?("take profit") }
        if tp_cell.blank?
          @found = false
          return self
        end
        @tp = tp_cell.css(".signal-price").text.match(/\d*\.\d*/).to_s.to_f

        sl_cell = cell.css(".row").to_a.find { |s| s.text.downcase.include?("stop loss") }
        if sl_cell.blank?
          @found = false
          return self
        end
        @sl = sl_cell.css(".signal-price").text.match(/\d*\.\d*/).to_s.to_f

        @found = true
        self
      end

      def tpsl
        if @found
          {
            entry: @entry,
            take_profit: @tp,
            stop_loss: @sl
          }
        elsif @sold
          { sold: true }
        else
          {}
        end
      end

    end

  end

end
