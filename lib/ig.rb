module IG
  class Service
    def initialize
      uri = URI('https://api.ig.com/gateway/deal/session')
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new uri

        request["X-IG-API-KEY"] = ENV["IG_API_KEY"]
        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json; charset=UTF-8"

        res = http.request(request, {
          "identifier" => ENV["IG_USERNAME"],
          "password" => ENV["IG_PASSWORD"]
        }.to_json)

        @cst = res.header["CST"]
        @xst = res.header["X-SECURITY-TOKEN"]
      end
    end

    def xst
      @xst
    end

    def cst
      @cst
    end

    def watchlist(list_id)
      uri = URI("https://api.ig.com/gateway/deal/watchlists/#{list_id}")
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new uri

        request["X-IG-API-KEY"] = ENV["IG_API_KEY"]
        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json; charset=UTF-8"
        request["X-SECURITY-TOKEN"] = xst
        request["CST"] = cst

        res = http.request(request)

        # puts res.body
        # puts "===" * 20
        # puts res.code
        JSON.parse(res.body)
      end
    end

    def watchlists
      uri = URI('https://api.ig.com/gateway/deal/watchlists')
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new uri

        request["X-IG-API-KEY"] = ENV["IG_API_KEY"]
        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json; charset=UTF-8"
        request["X-SECURITY-TOKEN"] = xst
        request["CST"] = cst

        res = http.request(request)

        # puts res.body
        # puts "===" * 20
        # puts res.code
        JSON.parse(res.body)
      end
    end
  end
end




