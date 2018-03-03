module IG
  class Service

    DEAL_HOST = "https://deal.ig.com"

    def initialize
      authorize!
    end

    def authorize!
      uri = URI("#{ENV['IG_API_HOST']}/gateway/deal/session")

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new uri

        request["X-IG-API-KEY"] = ENV["IG_API_KEY"]
        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json; charset=UTF-8"

        res = http.request(request, {
          "identifier" => ENV["IG_USERNAME"],
          "password" => ENV["IG_PASSWORD"]
        }.to_json)
        puts res.code

        @cst = res.header["CST"]
        puts @cst
        @xst = res.header["X-SECURITY-TOKEN"]
        puts xst
      end
    end

    def xst
      @xst
    end

    def cst
      @cst
    end

    def send_request(method, url, headers = {}, body = nil, extra_options = {})
      case method 
      when :get
        klass = Net::HTTP::Get
      when :post
        klass = Net::HTTP::Post
      end

      puts "#{method.to_s.upcase} #{url}"
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = klass.new uri

        headers.each do |key, value|
          request[key] = value
        end

        request["X-IG-API-KEY"] = ENV["IG_API_KEY"]
        request["Content-Type"] = "application/json; charset=UTF-8"
        request["Accept"] = "application/json; charset=UTF-8"
        request["X-SECURITY-TOKEN"] ||= xst
        request["CST"] ||= cst
        request["IG-ACCOUNT-ID"] = ENV["IG_ACCOUNT_ID"]

        res = http.request(request, body)
        puts res.code

        JSON.parse(res.body)
      end
    end

    def get(path, options = {})
      send_request(
        :get, 
        "#{ENV['IG_API_HOST']}/#{path}", 
        options[:headers], 
        options[:body]
      )
    end

    def post(path, options)
      send_request(
        :post,
        "#{ENV['IG_API_HOST']}/#{path}",
        options[:headers], 
        options[:body]
      )
    end

    def watchlist(list_id)
      get("gateway/deal/watchlists/#{list_id}")
    end

    def watchlists
      get("gateway/deal/watchlists")
    end

    def signals
      get("#{DEAL_HOST}/signals-gateway/signalsFiltered/0/1000", 
          cst: "",
          xst: ""
         )
    end
    
    def price(epic, start_date, end_date, page_number = 1)
      resolution = "MINUTE"

      get("gateway/deal/prices/#{epic}?resolution=#{resolution}&from=#{start_date}&to=#{end_date}&pageSize=20&pageNumber=#{page_number}", headers: { "Version" => "3" })
    end

    # Reference: https://labs.ig.com/rest-trading-api-reference/service-detail?id=542
    def open_position(pair, options)
      body = {
        "epic": pair.ig_epic,
        "expiry": "-",
        "direction": "BUY",
        "size": "1",
        "orderType": "MARKET",
        "timeInForce": "EXECUTE_AND_ELIMINATE",
        "level": nil,
        "guaranteedStop": "false",
        "stopLevel": nil,
        "stopDistance": nil,
        "trailingStop": nil,
        "trailingStopIncrement": nil,
        "forceOpen": "true",
        "limitLevel": nil,
        "limitDistance": nil,
        "quoteId": nil,
        "currencyCode": "AUD"
      }

      options.except(:headers).each do |key, value|
        body[key.to_s] = value
      end

      post("gateway/deal/positions/otc", {
        headers: options[:headers],
        body: body.to_json
      })
    end

    def orders
      get("gateway/deal/workingorders", headers: { "Version" => "2" })
    end

    def create_order(pair, options = {})
      body = {
        "epic": pair.ig_epic,
        "expiry": "-",
        "direction": "BUY",
        "size": "1",
        "level": "1.0", # when to enter
        "forceOpen": true,
        "type": "STOP",
        "currencyCode": "USD",
        "timeInForce": "GOOD_TILL_DATE", # or GOOD_TILL_CANCELLED
        "goodTillDate": (Time.now + 48.hours).strftime("%Y/%m/%d %H:%M:%S"),
        "guaranteedStop": false,
        "stopLevel": nil,
        "stopDistance": nil,
        "limitLevel": nil,
        "limitDistance": nil
      }

      options.except(:headers).each do |key, value|
        body[key.to_s] = value
      end

      post("gateway/deal/workingorders/otc",
        headers: (options[:headers] || {}).merge("Version" => "2"),
        body: body.to_json
      )
    end

  end
end
