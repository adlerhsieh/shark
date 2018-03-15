class RemoveUnusedColumnsInSignals < ActiveRecord::Migration[5.1]
  def change
    remove_column :fx_signals, :opened_at
    remove_column :fx_signals, :closed
    remove_column :fx_signals, :closed_at
    remove_column :fx_signals, :closed_price
  end
end
