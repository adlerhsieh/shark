class Position < ApplicationRecord

  include DealHelper

  has_many :logs, class_name: "AuditLog", as: :source
  
  belongs_to :pair
  belongs_to :signal, class_name: "FxSignal", foreign_key: :signal_id, optional: true
  belongs_to :source, optional: true
  belongs_to :order, optional: true

  def ig_open_position
    IG::OpenPositionJob.perform_later(id)
  end

  def ig_update_tpsl
    IG::UpdatePositionJob.perform_later(id)
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

  # {
  #   entry: 1.0,
  #   take_profit: 1.1,
  #   stop_loss: 1.2
  # }
  def update_on(tpsl)
    # if response from ig hasn't come back and update entry
    if entry.present?
      entry_diff = entry - tpsl[:entry].to_f
      tpsl[:take_profit] += entry_diff
      tpsl[:stop_loss] += entry_diff
    end
    
    update(tpsl.except(:entry))
  end

  def self.daily_report
    select("created_at, count(*) as count, sum(pl) as pl")
    .group("date(created_at)")
    .order("created_at desc")
    .all
  end

end
