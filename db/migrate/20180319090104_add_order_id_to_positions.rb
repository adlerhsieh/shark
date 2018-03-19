class AddOrderIdToPositions < ActiveRecord::Migration[5.1]
  def change
    add_column :positions, :order_id, :integer

    add_index :positions, :order_id
  end
end
