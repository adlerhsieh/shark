class Lfs::UpdateTpSlJob < ApplicationJob
  queue_as :default

  def perform(signal_id)
    @signal = FxSignal.find(signal_id)

    return if @signal.source_ref.blank?

    service.login
    service.get(@signal.source_ref)
    cell = service.document.css(".signal-cell").to_a.find {s| s.text.include?(pair_text)}

    raise Crawler::SignalNotFound, "Failed locating #{@signal.pair.pair} for Signal ##{@signal.id} "\
      " on its reference page: #{@signal.source_ref}"

    tp_cell = cell.css(".row").to_a.find { |s| s.text.downcase.include?("take profit") }
    tp = tp_cell.css(".signal-price").text.match(/\d*\.\d*/).to_s

    sl_cell = cell.css(".row").to_a.find { |s| s.text.downcase.include?("stop loss") }
    sl = sl_cell.css(".signal-price").text.match(/\d*\.\d*/).to_s

    tpsl = {}
    tpsl.merge!(take_profit: tp.to_f) if tp.present?
    tpsl.merge!(stop_loss: sl.to_f) if sl.present?

    if (position = @signal.position) 
      position.update(tpsl)
      # position.ig_update_tpsl
    end
  end

  private

    def pair_text
      @position.pair.pair
    end

    def ref
      @position.source_ref
    end

    def service
      @service ||= Crawler::LiveForexSignals.new(app_host: Crawler::LiveForexSignals::HOST)
    end

end

