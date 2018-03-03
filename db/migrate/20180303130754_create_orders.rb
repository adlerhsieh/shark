class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.integer :pair_id
      t.string :ig_deal_id
      t.integer :position_id
      t.decimal :size, precision: 10, scale: 5 
      t.datetime :expired_at
      t.decimal :take_profit, precision: 10, scale: 5 
      t.decimal :stop_loss, precision: 10, scale: 5 

      t.timestamps
    end

    add_index :orders, :pair_id
    add_index :orders, :ig_deal_id
    add_index :orders, :position_id
  end
end
