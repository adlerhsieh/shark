class ApplicationJob < ActiveJob::Base

  private

    def log
      @log ||= AuditLog.create(event: self.class)
    end
end
