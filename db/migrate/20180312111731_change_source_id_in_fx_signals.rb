class ChangeSourceIdInFxSignals < ActiveRecord::Migration[5.1]
  def change
    change_column :fx_signals, :source_id, :integer

    add_column :fx_signals, :source_secondary_id, :string

    add_index :fx_signals, :source_secondary_id
  end
end
