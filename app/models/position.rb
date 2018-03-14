class Position < ApplicationRecord

  include DealHelper

  has_many :logs, class_name: "AuditLog", as: :source

  has_one :order
  
  belongs_to :pair
  belongs_to :signal, class_name: "FxSignal", foreign_key: :signal_id, optional: true
  belongs_to :source, optional: true

  def ig_open_position
    IgOpenPositionJob.perform_later(id)
  end

  def ig_update_tpsl
    IgUpdatePositionJob.perform_later(id)
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

  def opposite_direction
    buy? ? "sell" : "buy"
  end

end
