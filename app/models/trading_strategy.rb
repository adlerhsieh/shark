class TradingStrategy < ApplicationRecord

  has_many :sources_trading_strategies
  has_many :sources, through: :sources_trading_strategies

  def name
    super.to_sym
  end

end
