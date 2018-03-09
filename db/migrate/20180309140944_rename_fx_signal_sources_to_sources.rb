class RenameFxSignalSourcesToSources < ActiveRecord::Migration[5.1]
  def change
    rename_table :fx_signal_sources, :sources
  end
end
