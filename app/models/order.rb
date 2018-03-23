class Order < ApplicationRecord

  include DealHelper
  delegate :opened?, :closed?, to: :position, allow_nil: true

  has_many :logs, class_name: "AuditLog", as: :source

  has_one :position

  belongs_to :pair
  belongs_to :source, optional: true
  belongs_to :signal, class_name: "FxSignal", optional: true, foreign_key: :signal_id

  validates :pair_id, presence: true
  validates :direction, presence: true
  validates :size, presence: true
  validates :entry, presence: true

  def ig_place_order
    IG::PlaceOrderJob.perform_later(id)
  end

  def ig_remove_order
    IG::RemoveOrderJob.perform_later(id)
  end

  def expired?
    expired_at.try(:<, Time.now) || false
  end

end
