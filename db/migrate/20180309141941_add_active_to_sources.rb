class AddActiveToSources < ActiveRecord::Migration[5.1]
  def change
    add_column :sources, :active, :boolean, default: false
  end
end
