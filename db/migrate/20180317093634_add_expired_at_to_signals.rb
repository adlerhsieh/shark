class AddExpiredAtToSignals < ActiveRecord::Migration[5.1]
  def change
    add_column :fx_signals, :expired_at, :datetime
  end
end
