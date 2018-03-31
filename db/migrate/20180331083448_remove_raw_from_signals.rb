class RemoveRawFromSignals < ActiveRecord::Migration[5.1]
  def change
    remove_column :fx_signals, :raw, :text
  end
end
