class AddClosedPriceToSignals < ActiveRecord::Migration[5.1]
  def change
    add_column :fx_signals, :closed_price, :decimal, precision: 10, scale: 5, before: :closed_at

    add_index :fx_signals, :created_at
  end
end
