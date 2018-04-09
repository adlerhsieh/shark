class Pair < ApplicationRecord

  has_many :signals, class_name: "FxSignal", foreign_key: :pair_id
  has_many :positions
  has_many :orders

  def pair(show_mini = true)
    "#{base}/#{quote} #{"MINI" if show_mini && mini?}".squish
  end

  def pip(unit = 1)
    if quote.downcase == "jpy"
      unit * 0.01
    else
      unit * 0.0001
    end
  end

  def redis_current_price_key
    "/pairs/#{id}/prices/current"
  end

  def redis_price_update_key
    "/pairs/#{id}/prices/updating"
  end

end
