class AddSignalIdToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :signal_id, :integer

    add_index :orders, :signal_id
  end
end
