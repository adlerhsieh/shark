class Position < ApplicationRecord

  include DealHelper

  has_one :order
  belongs_to :pair
  belongs_to :source, optional: true

  def profit?
    return if closed.blank?

    if buy?
      closed > entry
    else
      closed < entry
    end
  end

  def loss?
    return if closed.blank?

    !profit?
  end

end
