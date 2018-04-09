module IG
  class UpdatePairPriceJob < ApplicationJob
    queue_as :default

    def perform(pair_id)
      @pair = Pair.find(pair_id)

      return if $redis.get(@pair.redis_price_update_key).present?

      loop do
        res = Timeout.timeout(10) { service.show(@pair.ig_epic) }

        info = res["snapshot"].slice(*%w[marketStatus bid offer high low])

        $redis.set(@pair.redis_current_price_key, info.to_json)
        $redis.setex(@pair.redis_price_update_key, 120, true)
        sleep(10)
      end
    end

    private

      def service
        @serivce ||= IG::Service::Market.new
      end

  end
end
