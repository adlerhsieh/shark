class UpdateAllAvailableSignalsJob < ApplicationJob
  queue_as :default
 
  def perform
    log.write("Task started")
    if signals.blank?
      log.write("No available signals")
      return
    end

    service = IG::Service.new
    log.write("Logged in: #{Time.current}")

    signals.each do |signal|
      log.write("Processing: #{signal.id}: #{signal.pair.pair}")
      price_list = IG::PriceCollect.new(signal, service).collect

      IG::SignalUpdate.new(price_list, signal.id).update!
      log.write("Updated: signal evaluated_at to #{signal.reload.evaluated_at}")
    end
  rescue => ex
    log.write("#{ex}\n#{ex.backtrace.join('\n')}")
    $slack.ping("Error when executing #{self.class}. Check audit log for more info.") if Rails.env.production?
  end

  private

    def log
      @log ||= AuditLog.create(event: self.class)
    end

    def signals
      @signals ||= FxSignal.includes(:pair).recent.in_progress
    end

end

