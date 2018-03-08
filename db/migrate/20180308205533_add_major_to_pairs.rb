class AddMajorToPairs < ActiveRecord::Migration[5.1]
  def change
    add_column :pairs, :forex_category, :string

    add_index :pairs, :forex_category
  end
end
