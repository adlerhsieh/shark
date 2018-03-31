module IG

  class ClosePositionJob < ApplicationJob
    queue_as :default

    def perform(position_id)
      log.write("position ##{position_id}")
      @position = Position.find(position_id)
      log.update(source: @position)
      log.write("Sending request")

      response = service.close(@position)

      log.write("Response: #{response.to_s}")
      if response.present? && response["dealReference"]
        @position.update(ig_deal_reference: response["dealReference"])
        log.write("Reference: #{@position.ig_deal_reference}")
      else
        log.write("No reference present")
      end
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

