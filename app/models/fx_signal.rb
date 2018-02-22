class FxSignal < ApplicationRecord

  belongs_to :pair

  scope :recent, -> { where("created_at > ?", (Date.today - 1.day).to_s + " 00:00:00") }
  scope :closed, -> { where.not(closed_at: nil) }
  scope :opened, -> { where.not(opened_at: nil).where(closed_at: nil) }
  scope :in_progress, -> { where(closed_at: nil) }
  scope :pending, -> { where(opened_at: nil) }

  before_create :init_evaluated_at

  def opened?
    opened_at.present? && closed_at.blank?
  end

  def closed?
    closed_at.present?
  end

  def pending?
    opened_at.blank? && closed_at.blank?
  end

  def source
    
  end

  def init_evaluated_at
    self.evaluated_at ||= Time.current
  end

  def long?
    direction == "buy"
  end

  def short?
    direction == "sell"
  end

end
