class FxSignal::Generator::Base

  def log
    @log ||= AuditLog.create(event: self.class)
  end

  def expired?
    time = @document.payload.headers.find {|h| h.name == "Received" }.value.split(";").last.squish
    (Time.parse(time).in_time_zone + 24.hours) < Time.current
  end

end
