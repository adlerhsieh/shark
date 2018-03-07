class ApplicationJob < ActiveJob::Base

  def log
    @log ||= AuditLog.create(event: self.class)
  end

end
