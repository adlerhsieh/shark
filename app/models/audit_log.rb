class AuditLog < ApplicationRecord

  belongs_to :source, polymorphic: true, optional: true

  def write(message)
    update(content: self.content.to_s + message + "\n")
  end

  def error(ex)
    write("#{ex}\n#{ex.backtrace.join("\n")}")
    # $slack.ping("Error when executing #{self.class}. Check audit log for more info.") if Rails.env.production?
  end
end
