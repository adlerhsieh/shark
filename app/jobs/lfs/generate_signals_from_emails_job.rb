class Lfs::GenerateSignalsFromEmailsJob < ApplicationJob
  queue_as :default

  def perform
    messages.messages.each do |m|
      next if FxSignal.exists?(source_secondary_id: m.id)

      message = service.message(m.id)
      data    = message.payload.body.data

      next if data.blank?

      matched = data.match(/(buy|sell) (\S{3})\/(\S{3})/i)

      next if matched.blank?

      direction = matched[1].downcase
      pair = Pair.find_by(base: matched[2], quote: matched[3])

      signal = FxSignal.create(
        source: Source.find_or_create_by(name: "live-forex-signals.com"),
        source_secondary_id: m.id,
        terminated_at: Time.current + 4.hours,
        pair: pair,
        direction: direction
      )

      signal.open_position!
    end

  rescue Timeout::Error
    log.write("Timeout. The token might be expired.")
  end

  private

    def messages
      Timeout::timeout(10) { service.lf }
    end

    def service
      @service ||= Gmail::Service.new
    end

end

