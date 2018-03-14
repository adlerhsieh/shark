# Not used
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

  rescue ::IG::Service::NotAvailable => ex
    log.write("Error: #{ex}")
  rescue => ex
    log.error(ex)
  end

  private

    def signals
      @signals ||= FxSignal.includes(:pair).recent.in_progress
    end

end

