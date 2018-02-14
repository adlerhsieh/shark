class CreateSharkSignals < ActiveRecord::Migration[5.1]
  def change
    create_table :shark_signals do |t|
      t.string :gmail_id
      t.string :raw
      t.string :signal
      t.integer :pair_id
      t.decimal :enter, precision: 10, scale: 5
      t.decimal :tp, precision: 10, scale: 5
      t.decimal :sl, precision: 10, scale: 5

      t.timestamps
    end

    add_index :shark_signals, :pair_id
  end
end
