class AddSignalTypeToFxSignals < ActiveRecord::Migration[5.1]
  def change
    add_column :fx_signals, :target_resource, :string
    add_column :fx_signals, :action, :string
  end
end
