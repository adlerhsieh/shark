module IG
  class TerminatePositionJob < ApplicationJob
    queue_as :default

    def perform(position_id)
      log.write("position ##{position_id}")
      @position = Position.find(position_id)
      log.update(source: @position)

      log.write(@position.attributes.to_s)
      log.write("Sending request")
      response = service.close(@position)

      log.write("Response: #{response.to_s}")
      if response.present? && response["dealReference"]
        log.write("Reference: #{@position.ig_deal_reference}")
      elsif response["errorCode"].to_s.include?("No position found")
        log.write("Deal not found. Possibly it's already closed.")
        return
      else
        log.write("No reference present")
      end

      log.write("Confirming status")
      confirmation = service.confirm(@position.ig_deal_reference)

      log.write("Status: #{confirmation["dealStatus"]}")
      log.write(confirmation.to_s)

      # Possibly we can remove this since it's 
      # handled in ig_update_closed_positions_job
      @position.update(closed_at: Time.current)
    end

    private

      def service
        @service ||= IG::Service::Position.new
      end

  end
end
