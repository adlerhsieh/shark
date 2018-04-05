class AddDefaultToSourcesTradingStrategies < ActiveRecord::Migration[5.1]
  def change
    add_column :sources_trading_strategies, :default_strategy, :boolean, default: false

    add_column :sources_trading_strategies, :virtual_trade, :boolean, default: true
    remove_column :trading_strategies, :virtual
  end
end
