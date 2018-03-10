class AuditLog < ApplicationRecord

  belongs_to :source, polymorphic: true, optional: true

  def write(message)
    puts message
    update(content: self.content.to_s + message + "\n")
  end

  def error(ex)
    write("#{ex}\n#{ex.backtrace.join("\n")}")

    Raven.capture_exception(ex)
  end
end
