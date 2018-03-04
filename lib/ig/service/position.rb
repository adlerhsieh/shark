module IG

  module Service

    class Position < IG::Service::Base

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

    end

  end

end
