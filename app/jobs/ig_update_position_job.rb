class IgUpdatePositionJob < ApplicationJob
  queue_as :default

  def perform(position_id)
    @position = Position.find(position_id)
    log.update(source: @position)
    log.write(@position.attributes.to_s)

    log.write("Sending request")
    response = service.update(@position.ig_deal_id,
                 take_profit: @position.take_profit,
                 stop_loss: @position.stop_loss
               )

    log.write("Response: #{response.to_s}")
    if response.present? && response["dealReference"]
      log.write("Reference: #{response["dealReference"]}")
    else
      log.write("No reference present")
    end

    log.write("Confirming status")
    confirmation = service.confirm(response["dealReference"])

    log.write("Status: #{confirmation["dealStatus"]}")
    log.write(confirmation.to_s)
  end

  private

    def service
      @service ||= IG::Service::Position.new
    end

end
