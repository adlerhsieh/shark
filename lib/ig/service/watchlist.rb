module IG

  module Service

    class Watchlist < IG::Service::Base
      
      def find(list_id)
        get("gateway/deal/watchlists/#{list_id}")
      end

      def all
        get("gateway/deal/watchlists")
      end

    end

  end

end
