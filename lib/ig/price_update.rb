module IG
  class PriceUpdate
    attr_reader :prices, :signal, :opened_at, :closed_at, :closed_price

    def initialize(price_list, signal)
      @prices = parse_list(price_list)
      @signal = signal
    end

    def update!
      case signal.direction
      when "buy"
        long_trade!
      when "sell"
        short_trade!
      end
    end

    private

      def parse_list(list)
        list["prices"].map do |price|
          Price.new(price)
        end
      end

      def long_trade!
        prices.each do |price|
          break if signal.opened_at && signal.closed_at

          if signal.opened_at.nil? && signal.entry >= price.low.ask && signal.entry <= price.high.ask
            signal.update(opened_at: price.time)
          end

          next if signal.reload.opened_at.blank?

          if price.high.bid >= signal.take_profit
            signal.update(closed_at: price.time, closed: signal.take_profit)
          elsif price.low.bid <= signal.stop_loss
            signal.update(closed_at: price.time, closed: signal.stop_loss)
          end
        end
      end

      def short_trade!
        prices.each do |price|
          break if signal.opened_at && signal.closed_at

          if signal.opened_at.nil? && signal.entry <= price.high.bid && signal.entry >= price.low.bid
            signal.update(opened_at: price.time)
          end

          next if signal.reload.opened_at.blank?

          if price.low.ask <= signal.take_profit
            signal.update(closed_at: price.time, closed: signal.take_profit)
          elsif price.high.ask >= signal.stop_loss
            signal.update(closed_at: price.time, closed: signal.stop_loss)
          end
        end
      end

  end
end
