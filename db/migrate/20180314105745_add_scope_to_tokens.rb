class AddScopeToTokens < ActiveRecord::Migration[5.1]
  def change
    add_column :tokens, :scope, :string

    add_index :tokens, :name
    add_index :tokens, :scope
  end
end
