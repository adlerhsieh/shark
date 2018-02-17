module IG
  class PriceUpdate
    attr_reader :prices, :opened_at, :closed_at, :closed_price, :result

    def initialize(price_list, signal)
      @prices = parse_list(price_list)
      @signal = signal
    end

    def update!
      scan

      @signal.update(

      )
    end

    private

      def parse_list(list)
        list["prices"].map do |price|
          Price.new(price)
        end
      end

      def scan
        
      end

      def opened?
        opened_at.present? && !closed?
      end

      def closed?
        closed_at.present?
      end
  end
end
