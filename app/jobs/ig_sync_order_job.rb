class IgSyncOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    log.write("order ##{order_id}")
    @order = Order.find(order_id)
    log.update(source: @order)

    log.write(@order.attributes.to_s)
    log.write("Sending request")
    response = service.create(@order.pair, {
      direction:  @order.direction.upcase,
      size:       @order.size.to_i.to_s,
      level:      @order.entry.to_s,
      stopLevel:  @order.stop_loss&.to_s,
      limitLevel: @order.take_profit&.to_s
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
  rescue => ex
    log.error(ex)
  end

  private

    def service
      @service ||= IG::Service::Order.new
    end

end
