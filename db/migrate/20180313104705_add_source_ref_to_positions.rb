class AddSourceRefToPositions < ActiveRecord::Migration[5.1]
  def change
    add_column :positions, :source_ref, :string
  end
end
