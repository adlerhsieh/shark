class RenameTradingStrategiesSources < ActiveRecord::Migration[5.1]
  def change
    rename_table :trading_strategies_sources, :sources_trading_strategies
  end
end
