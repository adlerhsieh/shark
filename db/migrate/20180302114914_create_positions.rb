class CreatePositions < ActiveRecord::Migration[5.1]
  def change
    create_table :positions do |t|
      t.integer :pair_id
      t.string :direction
      t.decimal :entry, precision: 10, scale: 5 
      t.decimal :take_profit, precision: 10, scale: 5 
      t.decimal :stop_loss, precision: 10, scale: 5 
      t.datetime :opened_at
      t.decimal :closed, precision: 10, scale: 5 
      t.datetime :closed_at

      t.timestamps
    end
  end
end
