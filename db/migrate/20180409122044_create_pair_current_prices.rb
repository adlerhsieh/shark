class CreatePairCurrentPrices < ActiveRecord::Migration[5.1]
  def change
    create_table :pair_current_prices do |t|
      t.decimal :bid, precision: 10, scale: 5
      t.decimal :offer, precision: 10, scale: 5
      t.integer :pair_id

      t.timestamps
    end

    add_index :pair_current_prices, :pair_id
  end
end
