class Position < ApplicationRecord

  has_one :order
  belongs_to :pair

  def buy?
    direction == "buy"
  end

  def sell?
    direction == "sell"
  end

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
