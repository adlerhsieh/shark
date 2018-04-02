class FxSignal::Generator::Base

  def log
    @log ||= AuditLog.create(event: self.class)
  end

  def expired?
    time = @document.payload.headers.find {|h| h.name == "Received" }.value.split(";").last.squish
    parsed_time = Time.parse(time).in_time_zone + 24.hours
    if parsed_time < Time.current
      puts "Skipped: signal expired. Signal time: #{parsed_time} Current time: #{Time.current}"
      true
    else
      false
    end
  end

  def data
    @data ||= (
      @document.payload.try(:parts).try(:first).try(:body).try(:data) || 
      @document.payload.try(:body).try(:data)
    )
  end

end
