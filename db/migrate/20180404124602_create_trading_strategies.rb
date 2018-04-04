class CreateTradingStrategies < ActiveRecord::Migration[5.1]
  def change
    create_table :trading_strategies do |t|
      t.string :name
      t.text :description
      t.boolean :virtual, default: true

      t.timestamps
    end

    add_column :sources, :virtual, :boolean, default: true
  end
end
