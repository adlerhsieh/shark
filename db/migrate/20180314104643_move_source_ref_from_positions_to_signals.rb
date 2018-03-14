class MoveSourceRefFromPositionsToSignals < ActiveRecord::Migration[5.1]
  def change
    remove_column :positions, :source_ref, :string

    add_column :fx_signals, :source_ref, :string, limit: 800
  end
end
