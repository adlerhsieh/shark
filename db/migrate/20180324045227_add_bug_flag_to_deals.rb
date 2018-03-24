class AddBugFlagToDeals < ActiveRecord::Migration[5.1]
  def change
    add_column :fx_signals, :issue, :boolean, default: false
    add_column :orders, :issue, :boolean, default: false
    add_column :positions, :issue, :boolean, default: false
  end
end
