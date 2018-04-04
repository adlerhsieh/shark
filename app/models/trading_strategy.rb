class TradingStrategy < ApplicationRecord

  has_many :trading_strategies_sources
  has_many :sources, through: :trading_strategies_sources

end
