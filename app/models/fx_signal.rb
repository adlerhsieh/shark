class FxSignal < ApplicationRecord

  include DealHelper

  has_many :logs, class_name: "AuditLog", as: :source

  belongs_to :pair
  belongs_to :source, class_name: "Source", optional: true

  scope :recent, -> { where("created_at > ?", (Date.today - 1.day).to_s + " 00:00:00") }
  scope :closed, -> { where.not(closed_at: nil) }
  scope :opened, -> { where.not(opened_at: nil).where(closed_at: nil) }
  scope :in_progress, -> { where(closed_at: nil) }
  scope :pending, -> { where(opened_at: nil) }

  before_create :init_evaluated_at

  def pending?
    opened_at.blank? && closed_at.blank?
  end

  def init_evaluated_at
    self.evaluated_at ||= Time.current
  end

end
