class Position < ApplicationRecord

  has_one :order
  belongs_to :pair

end
