class AddIgStatusToPairs < ActiveRecord::Migration[5.1]
  def change
    add_column :pairs, :ig_market_status, :string
  end
end
