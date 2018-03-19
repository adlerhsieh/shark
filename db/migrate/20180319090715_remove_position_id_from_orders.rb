class RemovePositionIdFromOrders < ActiveRecord::Migration[5.1]
  def change
    remove_column :orders, :position_id, :integer
  end
end
