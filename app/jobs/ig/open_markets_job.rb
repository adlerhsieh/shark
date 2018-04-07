module IG
  class OpenMarketsJob < ApplicationJob
    queue_as :default

    def perform
      Pair.where(ig_market_status: "closed").each do |pair|
        res = service.show(pair.ig_epic)

        status = res.dig("snapshot", "marketStatus").downcase

        if status == "tradeable"
          pair.update(ig_market_status: "open")
        end
      end
    end

    private

      def service
        @serivce ||= IG::Service::Market.new
      end

  end
end
