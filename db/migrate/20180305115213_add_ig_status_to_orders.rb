class AddIgStatusToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :ig_status, :string
  end
end
