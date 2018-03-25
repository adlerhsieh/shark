require_relative "./base"

module IG

  module Service

    class Price < IG::Service::Base

      def query(epic, start_time, end_time, page_number = 1, resolution = "minute")
        resolution.upcase!
        start_time = start_time.strftime("%Y-%m-%dT%H:%M:%S") if start_time.respond_to?(:strftime)
        end_time = end_time.strftime("%Y-%m-%dT%H:%M:%S") if end_time.respond_to?(:strftime)

        get("gateway/deal/prices/#{epic}?resolution=#{resolution}&from=#{start_time}&to=#{end_time}&pageSize=20&pageNumber=#{page_number}", headers: { "Version" => "3" })
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
