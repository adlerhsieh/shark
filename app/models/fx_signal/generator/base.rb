class FxSignal::Generator::Base

  def log
    @log ||= AuditLog.create(event: self.class)
  end

  def data
    @data ||= (
      @document.payload.try(:parts).try(:first).try(:body).try(:data) || 
      @document.payload.try(:body).try(:data)
    )
  end

end
