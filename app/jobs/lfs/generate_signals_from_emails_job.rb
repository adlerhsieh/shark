class Lfs::GenerateSignalsFromEmailsJob < ApplicationJob
  queue_as :default

  def perform
    messages.messages.each do |m|
      next if FxSignal.exists?(source_secondary_id: m.id)

      message = service.message(m.id)
      data    = message.payload.body.data

      next if data.blank?

      url = Nokogiri::HTML(data)
        .css("a").first
        .attributes["href"].value
        .split("?").first

      matched = data.match(/(buy|sell) (\S{3})\/(\S{3})/i)

      next if matched.blank?

      direction = matched[1].downcase
      pair = Pair.find_by(base: matched[2], quote: matched[3])

      signal = FxSignal.create(
        source: Source.find_or_create_by(name: "live-forex-signals.com"),
        source_secondary_id: m.id,
        terminated_at: Time.current + 4.hours,
        pair: pair,
        direction: direction,
        source_ref: url
      )

      # TODO: Might not happen but can be issue if ig_open position is slower
      #       than lfs/update_tp_sl_job. The latter requires the former to fill
      #       entry for a position to calculate tp & sl. Both of them are async.
      #       
      signal
        .create_position
        .ig_open_position

      Lfs::UpdateTpSlJob.perform_later(signal.id)
    end

  rescue Timeout::Error
    log.write("Timeout. The token might be expired.")
  end

  private

    def messages
      Timeout::timeout(20) { service.lf }
    end

    def service
      @service ||= Gmail::Service.new
    end

end

