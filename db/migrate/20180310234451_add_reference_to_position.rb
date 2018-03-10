class AddReferenceToPosition < ActiveRecord::Migration[5.1]
  def change
    add_column :positions, :ig_deal_reference, :string
    add_column :positions, :ig_status, :string
  end
end
