class AddLastUpdatedAtToFxSignals < ActiveRecord::Migration[5.1]
  def change
    add_column :fx_signals, :evaluated_at, :datetime
  end
end
