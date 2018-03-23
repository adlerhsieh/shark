require_relative "./base"

module IG

  module Service

    class Price < IG::Service::Base

      def query(epic, start_date, end_date, page_number = 1)
        resolution = "MINUTE"

        get("gateway/deal/prices/#{epic}?resolution=#{resolution}&from=#{start_date}&to=#{end_date}&pageSize=20&pageNumber=#{page_number}", headers: { "Version" => "3" })
      end

      def latest(epic)
        body = get("gateway/deal/markets/#{epic}",
                  headers: { "Version" => "3" }
               )

        {
          bid: body["snapshot"]["bid"],
          offer: body["snapshot"]["offer"]
        }
      end

    end

  end

end
