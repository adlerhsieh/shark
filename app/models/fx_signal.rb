class FxSignal < ApplicationRecord

  include DealHelper

  has_many :logs, class_name: "AuditLog", as: :source
  has_one :position, foreign_key: :signal_id
  has_one :order, foreign_key: :signal_id

  belongs_to :pair
  belongs_to :source, class_name: "Source", optional: true

  scope :recent, -> { where("created_at > ?", (Date.today - 1.day).to_s + " 00:00:00") }
  scope :closed, -> { where.not(closed_at: nil) }
  scope :opened, -> { where.not(opened_at: nil).where(closed_at: nil) }
  scope :in_progress, -> { where(closed_at: nil) }
  scope :pending, -> { where(opened_at: nil) }

  before_create :init_evaluated_at

  def create_position(options = {})
    Position.create!(
      pair_id: pair_id,
      direction: direction,
      size: options[:size] || 1,
      entry: entry,
      take_profit: take_profit,
      stop_loss: stop_loss,
      signal_id: id,
      source_id: source_id
    )
  end

  def create_order(options = {})
    Order.create!(
      pair_id: pair_id,
      direction: direction,
      size: options[:size] || 1,
      entry: entry,
      take_profit: take_profit,
      stop_loss: stop_loss,
      signal_id: id,
      source_id: source_id,
      expired_at: expired_at
    )
  end

  def pending?
    opened_at.blank? && closed_at.blank?
  end

  def init_evaluated_at
    self.evaluated_at ||= Time.current
  end

end
