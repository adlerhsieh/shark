class ApplicationJob < ActiveJob::Base

  # Try to solve "undefined method jid" for jobs
  include Sidekiq::Worker

  def log
    @log ||= AuditLog.create(event: self.class)
  end

end
