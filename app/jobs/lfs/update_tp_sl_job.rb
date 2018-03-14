class Lfs::UpdateTpSlJob < ApplicationJob
  queue_as :default

  def perform(signal_id)
    @signal = FxSignal.find(signal_id)
    log.update(source: @signal)

    if @signal.source_ref.blank?
      log.write("Skipped: No ref url")
      return 
    end

    tpsl = find_tpsl

    if tpsl[:sold]
      log.write("Skipped: signal already closed")
      return
    end

    log.write("TP/SL: #{tpsl}")

    if tpsl.blank?
      log.write("TP/SL not found. Try logging in again.")
      service.login
      tpsl = find_tpsl
      log.write("TP/SL: #{tpsl}")
    end

    if tpsl.blank?
      log.write("Skipped: TP/SL not found.")
    end

    @signal.update(tpsl)

    if (position = @signal.position) 
      position.update(tpsl)
      # position.ig_update_tpsl
    end
  end

  private

    def find_tpsl
      service.get(@signal.source_ref)

      finder = Crawler::LiveForexSignals::FindTpSl.new(
        service.document, 
        @signal.pair.pair(false)
      )

      finder.find.tpsl
    end

    def service
      @service ||= Crawler::LiveForexSignals.new(app_host: Crawler::LiveForexSignals::HOST)
    end

end

