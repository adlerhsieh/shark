class AddDealReferenceToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :ig_deal_reference, :string
  end
end
