module IG
  class PriceCollect

    def initialize(signal, service)
      @signal = signal
      @service = service
    end

    def single_day_collect(start_page, end_page, start_date, end_date)
      (start_page..end_page).map do |page_number|
        prices = @service.price(
          @signal.pair.ig_epic,
          start_date,
          end_date,
          page_number + 1
        )

        prices["prices"].map { |price| Price.new(price) }
      end.flatten
    end

    def collect
      if Time.current.day - @signal.evaluated_at.day >= 2
        raise StandardError, "evaluated_at is over 2 days old for Signal ##{@signal.id}"
      end

      if @signal.evaluated_at.day < Time.current.day
        single_day_collect(
          last_evaluated_page, 
          72, 
          @signal.evaluated_at.strftime("%Y-%m-%d"), 
          (@signal.evaluated_at + 1.day).strftime("%Y-%m-%d")
        ) +
        single_day_collect(
          0, 
          current_page, 
          Time.current.strftime("%Y-%m-%d"), 
          (Time.current + 1.day).strftime("%Y-%m-%d")
        )
      else
        single_day_collect(
          last_evaluated_page, 
          current_page, 
          @signal.evaluated_at.strftime("%Y-%m-%d"), 
          (@signal.evaluated_at + 1.day).strftime("%Y-%m-%d")
        )
      end
    end

    private

      def last_evaluated_page
        (@signal.evaluated_at - @signal.evaluated_at.beginning_of_day).to_i / 60 / 20
      end

      def current_page
        (Time.current - Time.current.beginning_of_day).to_i / 60 / 20
      end

  end
end
