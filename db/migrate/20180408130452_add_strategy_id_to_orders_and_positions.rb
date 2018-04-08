class AddStrategyIdToOrdersAndPositions < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :trading_strategy_id, :integer
    add_column :positions, :trading_strategy_id, :integer

    add_index :orders, :trading_strategy_id
    add_index :positions, :trading_strategy_id
  end
end
