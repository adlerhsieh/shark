class AddAbbrevToSources < ActiveRecord::Migration[5.1]
  def change
    add_column :sources, :abbreviation, :string
  end
end
