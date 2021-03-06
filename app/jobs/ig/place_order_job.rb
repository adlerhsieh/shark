module IG

  class PlaceOrderJob < ApplicationJob
    queue_as :default

    def perform(order_id)
      log.write("order ##{order_id}")
      @order = Order.find(order_id)
      log.update(source: @order)

      log.write(@order.attributes.to_s)
      log.write("Sending request")
      response = service.create(@order.pair, {
        direction:    @order.direction.upcase,
        size:         @order.size.to_i.to_s,
        level:        @order.entry.to_s,
        stopLevel:    @order.stop_loss&.to_s,
        limitLevel:   @order.take_profit&.to_s,
        goodTillDate: @order.expired_at.strftime("%Y/%m/%d %H:%M:%S"),
        type:         order_type
      })

      log.write("Response: #{response.to_s}")
      if response.present? && response["dealReference"]
        @order.update(ig_deal_reference: response["dealReference"])
        log.write("Reference: #{@order.ig_deal_reference}")
      else
        log.write("No reference present")
      end

      log.write("Confirming status")
      confirmation = service.confirm(@order.ig_deal_reference)


      log.write("Status: #{confirmation["dealStatus"]}")
      log.write(confirmation.to_s)
      @order.update(
        ig_deal_id: confirmation["dealId"],
        ig_status: confirmation["dealStatus"].downcase
      )
    rescue ::IG::Service::NotAvailable => ex
      log.write("Error: #{ex}")
    rescue JSON::ParserError => ex
      log.write("Error: #{ex}")
    rescue => ex
      log.error(ex)
    end

    private

      def order_type
        log.write("Getting current price for pair")
        prices = price.latest(@order.pair.ig_epic)
        
        if @order.buy?
          prices[:offer] > @order.entry ? "LIMIT" : "STOP"
        elsif @order.sell?
          prices[:bid] > @order.entry ? "STOP" : "LIMIT"
        end
      end

      def service
        @service ||= IG::Service::Order.new
      end

      def price
        @price ||= IG::Service::Price.new
      end

  end

end
