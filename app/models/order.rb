class Order < ApplicationRecord

  has_many :logs, class_name: "AuditLog", as: :source

  belongs_to :pair
  belongs_to :source, optional: true
  belongs_to :position, optional: true

  validates :pair_id, presence: true
  validates :direction, presence: true
  validates :size, presence: true
  validates :entry, presence: true

  def ig_place_order
    IgPlaceOrderJob.perform_later(id)
  end

  def ig_remove_order
    IgRemoveOrderJob.perform_later(id)
  end

  def buy?
    direction == "buy"
  end

  def sell?
    direction == "sell"
  end

  def expired?
    expired_at < Time.now
  end

  def closed?
    position.try(:closed_at).present?
  end

end
