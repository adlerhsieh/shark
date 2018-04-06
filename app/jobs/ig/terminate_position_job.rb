module IG
  class TerminatePositionJob < ApplicationJob
    queue_as :default

    def perform(position_id)
      log.write("position ##{position_id}")
      @position = Position.find(position_id)
      log.update(source: @position)

      if @position.pair.ig_market_status == "closed"
        log.write("Skipped: market closed")
        return
      end

      log.write(@position.attributes.to_s)
      log.write("Sending request")
      response = service.close(@position)

      log.write("Response: #{response.to_s}")
      if response.present? && (ref = response["dealReference"])
        log.write("Reference: #{ref}")
      elsif response["errorCode"].to_s.include?("No position found")
        log.write("Deal not found. Possibly it's already closed.")
        return
      else
        log.write("No reference present")
      end

      log.write("Confirming status")
      confirmation = service.confirm(ref)

      log.write("Status: #{confirmation["dealStatus"]}")
      log.write(confirmation.to_s)

      if confirmation["reason"].downcase == "market_offline"
        @position.pair.update(ig_market_status: "closed")
      end

      # TODO: validate if the success state is "accepted"
      return if confirmation["dealStatus"].downcase != "accepted"

      # Possibly we can remove this since it's 
      # handled in ig_update_closed_positions_job,
      # but we don't want to terminate multiple times
      # since the update_closed_positions job might
      # run later than the termination job runs again
      @position.update(closed_at: Time.current)
    end

    private

      def service
        @service ||= IG::Service::Position.new
      end

  end
end
