class Order < ApplicationRecord

  include DealHelper
  delegate :opened?, :closed?, to: :position, allow_nil: true

  has_many :logs, class_name: "AuditLog", as: :source
  has_many :fx_signals_orders
  has_many :fx_signals, through: :fx_signals_orders
  has_one :position
  alias signals fx_signals

  belongs_to :pair
  belongs_to :source, optional: true

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
