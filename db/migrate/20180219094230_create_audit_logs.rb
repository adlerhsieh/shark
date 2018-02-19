class CreateAuditLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :audit_logs do |t|
      t.integer :source_type
      t.integer :source_id
      t.string :event
      t.text :content

      t.timestamps
    end

    add_index :audit_logs, :source_type
    add_index :audit_logs, :source_id
  end
end
