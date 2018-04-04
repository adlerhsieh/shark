class CreateTradingStrategiesSources < ActiveRecord::Migration[5.1]
  def change
    create_table :trading_strategies_sources do |t|
      t.integer :trading_strategy_id
      t.integer :source_id

      t.timestamps
    end

    add_index :trading_strategies_sources, :trading_strategy_id
    add_index :trading_strategies_sources, :source_id
  end
end
