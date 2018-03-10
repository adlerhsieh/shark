module IG

  module Service

    class Position < IG::Service::Base

      def all
        get("gateway/deal/positions", 
            headers: { "Version" => "2" }
           )
      end

      # Reference: https://labs.ig.com/rest-trading-api-reference/service-detail?id=542
      def create(pair, options)
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
          "trailingStop": "false",
          "trailingStopIncrement": nil,
          "forceOpen": "true",
          "limitLevel": nil,
          "limitDistance": nil,
          "quoteId": nil,
          "currencyCode": pair.quote
        }

        options.except(:headers).each do |key, value|
          body[key.to_s] = value
        end

        post("gateway/deal/positions/otc", {
          headers: (options[:headers] || {}).merge("Version" => "2"),
          body: body.to_json
        })
      end

    end

  end

end
