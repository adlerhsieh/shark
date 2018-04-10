module IG
  class UpdatePairPriceJob < ApplicationJob
    queue_as :update_pair_price

    def perform(pair_id)
      @pair = Pair.find(pair_id)

      return if $redis.get(@pair.redis_price_update_key).present?

      loop do
        res = Timeout.timeout(10) { service.show(@pair.ig_epic) }

        info = res["snapshot"].slice(*%w[marketStatus bid offer high low])

        # $redis.set(@pair.redis_current_price_key, info.to_json)
        last_price = Pair::CurrentPrice.where(pair_id: pair_id)
                                       .order(created_at: :desc)
                                       .limit(1)
                                       .first

        unless last_price.present? && last_price.sell == info["bid"].to_f && last_price.buy == info["offer"].to_f
          Pair::CurrentPrice.create!(
            buy: info["offer"],
            sell: info["bid"],
            high: info["high"],
            low: info["low"],
            pair_id: pair_id
          ) 
        end

        $redis.setex(@pair.redis_price_update_key, 120, true)
        sleep(20)
      end
    end

    private

      def service
        @serivce ||= IG::Service::Market.new
      end

  end
end
