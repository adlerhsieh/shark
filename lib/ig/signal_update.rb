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

      def long_trade!
        puts "LONG"
        prices.each do |price|
          break if @signal.opened_at && @signal.closed_at

          if @signal.opened_at.nil? && @signal.entry >= price.low.ask && @signal.entry <= price.high.ask
            @signal.update(opened_at: price.time)
            $slack.ping("Signal ##{@signal.id} opened.") if Rails.env.production?
          end

          next if @signal.reload.opened_at.blank?

          puts "#{price.time}:"
          puts "  - LOW:  #{price.low.bid}"
          puts "  - HIGH: #{price.high.bid}"
          if price.high.bid >= @signal.take_profit
            @signal.update(closed_at: price.time, closed: @signal.take_profit)
            $slack.ping("Signal ##{@signal.id} closed.") if Rails.env.production?
          elsif price.low.bid <= @signal.stop_loss
            @signal.update(closed_at: price.time, closed: @signal.stop_loss)
            $slack.ping("Signal ##{@signal.id} closed.") if Rails.env.production?
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
