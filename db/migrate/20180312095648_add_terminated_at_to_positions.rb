class AddTerminatedAtToPositions < ActiveRecord::Migration[5.1]
  def change
    rename_column :fx_signals, :force_close_at, :terminated_at

    add_column :positions, :signal_id, :integer

    add_index :positions, :signal_id
  end
end
