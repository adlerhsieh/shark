require_relative "./base"

module IG

  module Service

    class Market < IG::Service::Base

      def show(ig_epic)
        get("gateway/deal/markets/#{ig_epic}", headers: { "Version" => "3" })
      end

    end

  end

end
