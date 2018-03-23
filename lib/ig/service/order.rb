require_relative "./base"

module IG

  module Service

    class Order < IG::Service::Base

      def all
        get("gateway/deal/workingorders", headers: { "Version" => "2" })
      end

      def create(pair, options = {})
        body = {
          "epic": pair.ig_epic,
          "expiry": "-",
          "direction": "BUY",
          "size": "1",
          "level": "1.0", # when to enter
          "forceOpen": true,
          # type => stop
          #   - buy:  target_price > current_price
          #   - sell: target_price < current_price
          # type => limit
          #   - buy:  target_price < current_price
          #   - sell: target_price > current_price
          "type": "LIMIT",
          "currencyCode": pair.quote,
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

      def remove(ig_deal_id)
        delete("gateway/deal/workingorders/otc/#{ig_deal_id}", headers: { "Version" => "2" })
      end

    end

  end

end
