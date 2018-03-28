class AddConfidenceToFxSignals < ActiveRecord::Migration[5.1]
  def change
    add_column :fx_signals, :confidence, :decimal, precision: 10, scale: 5
  end
end
