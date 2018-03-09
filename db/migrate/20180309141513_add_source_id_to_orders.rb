class AddSourceIdToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :source_id, :integer
    add_column :positions, :source_id, :integer

    add_index :orders, :source_id
    add_index :positions, :source_id
  end
end
