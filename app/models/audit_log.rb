class AuditLog < ApplicationRecord

  def write(message)
    update(content: self.content.to_s + message + "\n")
  end
end
