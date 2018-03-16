module IG

  class OpenPositionJob < ApplicationJob
    queue_as :default

    def perform(position_id)
      log.write("position ##{position_id}")
      @position = Position.find(position_id)
      log.update(source: @position)

      log.write(@position.attributes.to_s)
      log.write("Sending request")
      response = service.create(@position.pair, {
        direction:  @position.direction.upcase,
        size:       @position.size.to_i.to_s,
        stopLevel:  @position.stop_loss&.to_s,
        limitLevel: @position.take_profit&.to_s
      })

      log.write("Response: #{response.to_s}")
      if response.present? && response["dealReference"]
        @position.update(ig_deal_reference: response["dealReference"])
        log.write("Reference: #{@position.ig_deal_reference}")
      else
        log.write("No reference present")
      end

      log.write("Confirming status")
      confirmation = service.confirm(@position.ig_deal_reference)

      log.write("Status: #{confirmation["dealStatus"]}")
      log.write(confirmation.to_s)
      attrs = {
        ig_deal_id: confirmation["dealId"],
        ig_status: confirmation["dealStatus"].downcase,
        entry: confirmation["level"]
      }
      attrs.merge!(opened_at: "#{confirmation["date"]} UTC") if attrs[:ig_status].downcase == "accepted"
      @position.update(attrs)
    rescue ::IG::Service::NotAvailable => ex
      log.write("Error: #{ex}")
    rescue => ex
      log.error(ex)
    end

    private

      def service
        @service ||= IG::Service::Position.new
      end

  end

end
