class FxSignalProcessJob < ApplicationJob
  queue_as :default

  def perform(signal_id)
    signal = FxSignal.find(signal_id)

    log.update(source: signal)
    log.write("Processing signal action")

    if signal.expired_at < Time.current
      log.write("Skipped: signal expired")
      return
    end
    
    signal.process(log: log)
  rescue FxSignal::DealNotFound
    log.write("Deal not found. Wait until next round.")
    self.class.set(wait: 1.minute).perform_later(signal_id)
  end

end
