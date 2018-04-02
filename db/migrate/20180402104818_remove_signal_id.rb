class RemoveSignalId < ActiveRecord::Migration[5.1]
  def change
    remove_column :positions, :signal_id, :integer
    remove_column :orders, :signal_id, :integer
  end
end
