module IG
  class PriceUpdate
    attr_reader :prices, :signal, :opened_at, :closed_at, :closed_price

    def initialize(price_list, signal)
      @prices = parse_list(price_list)
      @signal = signal
    end

    def update!
      signal.opened_at ||= opened_at
      signal.closed ||= closed_at
      signal.closed_price ||= closed_price

      signal.save! if signal.changed?
    end

    private

      def parse_list(list)
        puts list["prices"].first
        list["prices"].map do |price|
          Price.new(price)
        end
      end

      def opened_at
        segment = prices.find do |price|
          signal.entry > price.low && signal.entry < price.high
        end

        Time.parse(segment.time) if segment
      end

      def closed_segment
        @closed_segment ||= prices.find do |price|
          (signal.take_profit > price.low && signal.take_profit < price.high) ||
            (signal.stop_loss > price.low && signal.stop_loss < price.high)
        end
      end

      def closed_at
        Time.parse(@closed_segment.time) if @closed_segment
      end

      def closed_price

      end

      def opened?
        opened_at.present? && !closed?
      end

      def closed?
        closed_at.present?
      end
  end
end
