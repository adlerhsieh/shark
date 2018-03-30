class CreateBlacklistEmails < ActiveRecord::Migration[5.1]
  def change
    create_table :blacklist_emails do |t|
      t.string :source
      t.string :source_id

      t.timestamps
    end

    add_index :blacklist_emails, :source
    add_index :blacklist_emails, :source_id
  end
end
