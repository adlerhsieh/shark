class IgRemoveOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    log.write("order ##{order_id}")
    @order = Order.find(order_id)
    log.update(source: @order)

    log.write("Sending request")
    response = service.remove(@order.ig_deal_id)
    log.write("Response: #{response.to_s}")

    log.write("Confirming status")
    confirmation = service.confirm(response["dealReference"])

    log.write("Status: #{confirmation["dealStatus"]}")
    log.write(confirmation.to_s)

    @order.update(deleted: true)
  end

  private

    def service
      @service ||= IG::Service::Order.new
    end

end

