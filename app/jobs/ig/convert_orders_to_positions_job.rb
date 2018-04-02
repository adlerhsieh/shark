module IG

  class ConvertOrdersToPositionsJob < ApplicationJob
    queue_as :default

    def perform
      log.write("Getting all positions from IG")
      log.write(positions.to_json)

      positions["positions"].each do |position|
        deal_id = position["position"]["dealId"]
        log.write("Processing #{deal_id}")

        position = Position.find_by(ig_deal_id: deal_id)
        next if position.present?

        order = Order.find_by(ig_deal_id: deal_id)
        if order.blank?
          log.write("Skipped: order not found")
          next
        end

        log.write("Matched order ##{order.id}")

        Position.create!(
          pair_id:     order.pair_id,
          ig_deal_id:  deal_id,
          direction:   order.direction,
          entry:       order.entry,
          size:        order.size,
          take_profit: order.take_profit,
          stop_loss:   order.stop_loss,
          order_id:    order.id,
          # There will be a gap of difference from the actual time of 
          # opening thie position, at most 8 minutes
          opened_at:   Time.now
        )
      end
      log.write("Done")

    rescue ::IG::Service::NotAvailable => ex
      log.write("Error: #{ex}")
    rescue => ex
      log.error(ex)
    end

    private

      def positions
        @positions ||= service.all
      end

      def service
        @service ||= IG::Service::Position.new
      end

  end

end
