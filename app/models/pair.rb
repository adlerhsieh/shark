class Pair < ApplicationRecord

  has_many :signals, class_name: "FxSignal", foreign_key: :pair_id

  def pair
    "#{base}/#{quote}"
  end

end
