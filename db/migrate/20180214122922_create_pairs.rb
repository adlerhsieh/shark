class CreatePairs < ActiveRecord::Migration[5.1]
  def change
    create_table :pairs do |t|
      t.string :base
      t.string :quote
      t.boolean :mini
      t.string :ig_epic

      t.timestamps
    end
  end
end
