class FxSignal::Generator::Base

  def log
    @log ||= AuditLog.create(event: self.class)
  end

end
