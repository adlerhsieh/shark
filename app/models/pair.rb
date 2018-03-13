class Pair < ApplicationRecord

  has_many :signals, class_name: "FxSignal", foreign_key: :pair_id
  has_many :positions
  has_many :orders

  def pair(show_mini = true)
    "#{base}/#{quote} #{"MINI" if show_mini && mini?}".squish
  end

end
