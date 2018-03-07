class IgConvertOrdersToPositionsJob < ApplicationJob
  queue_as :default

  def perform
    log.write("Getting all positions from IG")
    log.write(positions.to_json)

    positions["positions"].each do |position|
      deal_id = position["position"]["dealId"]
      log.write("Processing #{deal_id}")
      order = Order.find_by(position_id: nil, ig_deal_id: deal_id)

      next if order.blank?
      log.write("Matched order ##{order.id}")

      new_position = Position.create(
        pair_id:     order.pair_id,
        ig_deal_id:  deal_id,
        direction:   order.direction,
        entry:       order.entry,
        size:        order.size,
        take_profit: order.take_profit,
        stop_loss:   order.stop_loss,
        opened_at:   Time.parse("#{position["position"]["createdDateUTC"]} UTC")
      )

      log.write("Updating order with position_id #{new_position.id}")
      order.update(position_id: new_position.id)
    end
    log.write("Done")
  end

  private

    def positions
      @positions ||= service.all
    end

    def service
      @service ||= IG::Service::Position.new
    end

end
