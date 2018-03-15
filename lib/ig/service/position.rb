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
          "timeInForce": "FILL_OR_KILL",
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

      def update(deal_id, options = {})
        body = {
          "stopLevel": options[:stop_loss].to_f.to_s,
          "limitLevel": options[:take_profit].to_f.to_s,
          "trailingStop": "false",
          "trailingStopDistance": nil,
          "trailingStopIncrement": nil
        }

        put("gateway/deal/positions/otc/#{deal_id}",
            headers: (options[:headers] || {}).merge("Version" => "2"),
            body: body.to_json
           )
      end

      def close(position)
        body = {
            "dealId": position.ig_deal_id,
            "epic": nil,
            "expiry": nil,
            "direction": position.opposite_direction.upcase,
            "size": position.size.to_i.to_s,
            "level": nil,
            "orderType": "MARKET",
            "timeInForce": nil,
            "quoteId": nil
        }

        post("gateway/deal/positions/otc", {
              headers: {"Version" => "1", "_METHOD" => "DELETE" },
              body: body.to_json
             })
      end

    end

  end

end
