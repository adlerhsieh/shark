class Order < ApplicationRecord

  belongs_to :pair
  belongs_to :position, optional: true

  def ig_open
    
  end

end
