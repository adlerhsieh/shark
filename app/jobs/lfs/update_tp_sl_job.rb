class Lfs::UpdateTpSlJob < ApplicationJob
  queue_as :default

  def perform(position_id)
    @position = Position.find(position_id)

    return if @position.source_ref.blank?

    service.login
    service.get(@position.source_ref)
    cell = service.document.css(".signal-cell").to_a.find {s| s.text.include?(pair_text)}.text

    tp_cell = cell.css(".row").to_a.find { |s| s.text.downcase.include?("take profit") }
    tp = tp_cell.css(".signal-price").text.match(/\d*\.\d*/).to_s

    sl_cell = cell.css(".row").to_a.find { |s| s.text.downcase.include?("stop loss") }
    sl = sl_cell.css(".signal-price").text.match(/\d*\.\d*/).to_s

    tpsl = {}
    tpsl.merge!(take_profit: tp.to_f) if tp.present?
    tpsl.merge!(stop_loss: sl.to_f) if sl.present?

    @position.update(tpsl)
    @position.ig_update_tpsl
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

