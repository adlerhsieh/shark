class FxSignal < ApplicationRecord

  belongs_to :pair

  scope :recent, -> { where("created_at > ?", Date.today - 7.days) }
  scope :closed, -> { where.not(closed_at: nil) }
  scope :opened, -> { where.not(opened_at: nil).where(closed_at: nil) }
  scope :pending, -> { where(opened_at: nil) }

  def opened?
    opened_at.present? && closed_at.blank?
  end

  def closed?
    closed_at.present?
  end

  def pending?
    opened_at.blank? && closed_at.blank?
  end

  def self.update!
    service = IG::Service.new

    recent.each do |sig|
      sig.update_with(service.price(
        sig.pair.ig_epic,
        param(sig.created_at),
        param(sig.created_at + 1.day)
      ))
    end
  end

  def self.param(date)
    date.strftime("%Y-%m-%d")
  end

  def update_with(price_list)
    IG::PriceUpdate.new(price_list, self).update!
  end

end
