class RemoveHighLowFromPrices < ActiveRecord::Migration[5.1]
  def change
    remove_column :pair_current_prices, :high, :decimal
    remove_column :pair_current_prices, :low, :decimal
  end
end
