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

  # Only used on lfs now. 
  #
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

  def source
    super || order.try(:source)
  end

  def price_history
    start_time = if opened_at
                   opened_at - 2.hours
                 else
                   created_at
                 end
    end_time = if closed_at
                 closed_at + 2.hours
               else
                 Time.current
               end

    service = IG::Service::Price.new

    response = service.query(pair.ig_epic, start_time, end_time)
    response["prices"].map do |price|
      open_mid  = ((price["openPrice"]["bid"] + price["openPrice"]["ask"]) / 2).round(5)
      close_mid = ((price["closePrice"]["bid"] + price["closePrice"]["ask"]) / 2).round(5)
      high_mid  = ((price["highPrice"]["bid"] + price["highPrice"]["ask"]) / 2).round(5)
      low_mid   = ((price["lowPrice"]["bid"] + price["lowPrice"]["ask"]) / 2).round(5)

      # price_positions = [
      #   high_mid,
      #   open_mid,
      #   close_mid,
      #   low_mid
      # ]

      if open_mid <= close_mid
        price_positions = [
          low_mid,
          open_mid,
          close_mid,
          high_mid,
        ]
      else
        price_positions = [
          high_mid,
          open_mid,
          close_mid,
          low_mid
        ]

        # price_positions.reverse!
      end

      price_positions.unshift(Time.parse("#{price["snapshotTimeUTC"]} UTC").in_time_zone.strftime("%H:%M"))
    end
  end

end
