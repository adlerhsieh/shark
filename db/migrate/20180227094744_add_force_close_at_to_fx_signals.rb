class AddForceCloseAtToFxSignals < ActiveRecord::Migration[5.1]
  def change
    add_column :fx_signals, :force_close_at, :datetime
  end
end
