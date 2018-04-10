module IG
  class UpdatePairsPriceJob < ApplicationJob
    queue_as :update_pair_price

    def perform
      # pair_ids = Position.where(closed_at: nil).pluck(:pair_id)
      
      IG::UpdatePairPriceJob.perform_later(1)
    end

  end
end
