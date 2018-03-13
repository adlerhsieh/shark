class AddPlToPositions < ActiveRecord::Migration[5.1]
  def change
    add_column :positions, :pl, :decimal, precision: 10, scale: 5
    add_column :positions, :currency, :string
  end
end
