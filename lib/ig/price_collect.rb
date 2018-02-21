module IG
  class PriceCollect

    def initialize(signal)
      @signal = signal
    end

    def collect
      (last_evaluated_page..current_page).map do |page_number|
        prices = service.price(
          @signal.pair.ig_epic,
          @signal.evaluated_at.strftime("%Y-%m-%d"),
          (@signal.evaluated_at + 1.day).strftime("%Y-%m-%d"),
          page_number + 1
        )

        prices["prices"].map { |price| Price.new(price) }
      end.flatten
    end

    private

      def service
        @service ||= IG::Service.new
      end

      def next_day
        
      end

      def last_evaluated_page
        (@signal.evaluated_at - Time.current.beginning_of_day).to_i / 60 / 20
      end

      def current_page
        (Time.current - Time.current.beginning_of_day).to_i / 60 / 20
      end

  end
end
