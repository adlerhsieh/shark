class AddDeletedToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :deleted, :boolean, default: false

    add_index :orders, :deleted
  end
end
