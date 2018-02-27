class CreateFxSignalSources < ActiveRecord::Migration[5.1]
  def change
    create_table :fx_signal_sources do |t|
      t.string :name
      t.string :username

      t.timestamps
    end

    remove_column :fx_signals, :source_type
  end
end
