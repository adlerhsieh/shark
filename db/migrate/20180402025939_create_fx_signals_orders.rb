class CreateFxSignalsOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :fx_signals_orders do |t|
      t.integer :fx_signal_id
      t.integer :order_id

      t.timestamps
    end

    add_index :fx_signals_orders, :fx_signal_id
    add_index :fx_signals_orders, :order_id
  end
end
