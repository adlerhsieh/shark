class SourcesTradingStrategy < ApplicationRecord

  belongs_to :trading_strategy
  belongs_to :source

end