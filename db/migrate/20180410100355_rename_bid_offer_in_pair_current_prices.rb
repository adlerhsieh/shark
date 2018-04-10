class RenameBidOfferInPairCurrentPrices < ActiveRecord::Migration[5.1]
  def change
    rename_column :pair_current_prices, :bid, :buy
    rename_column :pair_current_prices, :offer, :sell

    add_column :pair_current_prices, :high, :decimal, precision: 10, scale: 5 
    add_column :pair_current_prices, :low, :decimal, precision: 10, scale: 5 
  end
end
