class CreateFxSignals < ActiveRecord::Migration[5.1]
  def change
    create_table :fx_signals do |t|
      t.string :source_id
      t.string :source_type
      t.integer :pair_id
      t.string :direction
      t.decimal :entry, precision: 10, scale: 5
      t.decimal :take_profit, precision: 10, scale: 5
      t.decimal :stop_loss, precision: 10, scale: 5
      t.datetime :opened_at
      t.decimal :closed, precision: 10, scale: 5
      t.datetime :closed_at
      t.text :raw

      t.timestamps
    end

    add_index :fx_signals, :source_id
    add_index :fx_signals, :source_type
    add_index :fx_signals, :pair_id
  end
end
