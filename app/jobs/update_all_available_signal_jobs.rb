class UpdateAllAvailableSignalsJob < ApplicationJob
  queue_as :default
 
  def perform
    service = IG::Service.new
    log.write("Logged in: #{Time.current}")

    FxSignal.includes(:pair).recent.in_progress.each do |signal|
      log.write("Processing: #{signal.id}: #{signal.pair.pair}")
      price_list = IG::PriceCollect.new(signal, service).collect

      IG::SignalUpdate.new(price_list, signal.id).update!
      log.write("Updated: signal evaluated_at to #{signal.reload.evaluated_at}")
    end
  end

  def log
    @log ||= AuditLog.create(event: self.class)
  end

end

