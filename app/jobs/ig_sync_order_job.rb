class SyncOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    log.write("order ##{order_id}")
    
  end

end
