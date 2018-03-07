require_relative "./base"

module IG

  module Service

    class Account < IG::Service::Base

      def transactions(start_time = (Time.current - 2.hour), end_time = Time.current, options = {})
        from = start_time.utc.strftime("%Y-%m-%dT%H:%M:%S")
        to   = end_time.utc.strftime("%Y-%m-%dT%H:%M:%S")

        querystring = [
          "type=ALL",
          "from=#{from}",
          "to=#{to}",
          "pageSize=#{options[:page_size] || 40}",
          "pageNumber=#{options[:page_number] || 1}"
        ].join("&")

        get(
          URI::encode("gateway/deal/history/transactions?#{querystring}"),
          headers: { "Version" => "2" }
        )
      end

    end

  end

end
