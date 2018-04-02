class CreateFxSignalsPositions < ActiveRecord::Migration[5.1]
  def change
    create_table :fx_signals_positions do |t|
      t.integer :fx_signal_id
      t.integer :position_id

      t.timestamps
    end

    add_index :fx_signals_positions, :fx_signal_id
    add_index :fx_signals_positions, :position_id
  end
end
