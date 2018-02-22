module ApplicationHelper
  def result_class(signal)
    return if signal.closed.nil?
    if (signal.long? && signal.closed < signal.entry) || (signal.short? && signal.closed > signal.entry)
      "danger"
    else
      "success"
    end
  end
end
