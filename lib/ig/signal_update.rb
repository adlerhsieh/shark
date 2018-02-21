module IG
  class SignalUpdate
    attr_reader :prices

    def initialize(price_list, signal_id)
      @prices = price_list
      @signal = FxSignal.find(signal_id)
    end

    def update!
      puts "looping"

      case @signal.direction
      when "buy"
        long_trade!
      when "sell"
        short_trade!
      end

      @signal.update(evaluated_at: @prices.last.time)
    end

    private

      # def parse_list(list)
      #   list["prices"].map do |price|
      #     Price.new(price)
      #   end
      # end

      def long_trade!
        puts "LONG"
        prices.each do |price|
          puts "#{price.time}:"
          break if @signal.opened_at && @signal.closed_at

          puts "  - LOW:  #{price.low.ask}"
          puts "  - HIGH: #{price.high.ask}"
          if @signal.opened_at.nil? && @signal.entry >= price.low.ask && @signal.entry <= price.high.ask
            @signal.update(opened_at: price.time)
            puts "OPENED!!!"
          end

          next if @signal.reload.opened_at.blank?

          puts "#{price.time}:"
          puts "  - LOW:  #{price.low.bid}"
          puts "  - HIGH: #{price.high.bid}"
          if price.high.bid >= @signal.take_profit
            puts "TAKE PROFIT"
            @signal.update(closed_at: price.time, closed: @signal.take_profit)
          elsif price.low.bid <= @signal.stop_loss
            puts "STOP LOSS"
            @signal.update(closed_at: price.time, closed: @signal.stop_loss)
          end
        end
      end

      def short_trade!
        prices.each do |price|
          break if @signal.opened_at && @signal.closed_at

          if @signal.opened_at.nil? && @signal.entry <= price.high.bid && @signal.entry >= price.low.bid
            @signal.update(opened_at: price.time)
          end

          next if @signal.reload.opened_at.blank?

          if price.low.ask <= @signal.take_profit
            @signal.update(closed_at: price.time, closed: @signal.take_profit)
          elsif price.high.ask >= @signal.stop_loss
            @signal.update(closed_at: price.time, closed: @signal.stop_loss)
          end
        end
      end

  end
end
