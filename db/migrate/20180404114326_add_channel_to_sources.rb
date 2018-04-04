class AddChannelToSources < ActiveRecord::Migration[5.1]
  def change
    add_column :sources, :channel, :string
  end
end
