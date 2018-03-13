class IgUpdatePositionJob < ApplicationJob
  queue_as :default

  def perform(position_id)
    @position = Position.find(position_id)

  end

end
