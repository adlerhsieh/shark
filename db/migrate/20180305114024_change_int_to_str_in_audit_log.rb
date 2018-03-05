class ChangeIntToStrInAuditLog < ActiveRecord::Migration[5.1]
  def change
    change_column :audit_logs, :source_type, :string
  end
end
