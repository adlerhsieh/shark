class AddTerminatedAtToOrdersAndPositions < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :terminated_at, :datetime
    add_column :positions, :terminated_at, :datetime
  end
end
