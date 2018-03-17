class Fs::GenerateSignalsFromEmailsJob < ApplicationJob
  queue_as :default

  def perform
    messages.messages.each do |m|
      if (fx_signal = FxSignal.find_by(source_secondary_id: m.id))
        log.write("Skipped: #{m.id} exists as FxSignal id #{fx_signal.id}")
        next
      end

      if expired?(m)
        log.write("Skipped: #{m.di} is too older than 24 hours")
      end

      attrs = {
        source_secondary_id: m.id,
        expired_at: Time.current + 3.days
      }

      message = service.message(m.id)
      data    = message.payload.parts.first.body.data

      parts = data.match(/\r\n(.*)\r\n.*(SHORT|LONG)[ ]?(\S{6})[ ]?@[ ]?(\d{0,5}\.\d{0,5})/)
      username = parts[1].squish
      attrs[:source] = Source.find_or_create_by(name: "forexsignals.com", username: username) { |source| source.active = true }

      attrs[:direction] = parts[2].to_s.downcase
      case attrs[:direction]
      when "long"
        attrs[:direction] = "buy"
      when "short"
        attrs[:direction] = "sell"
      end

      attrs[:pair] = Pair.find_by(
        base: parts[3][0..2],
        quote: parts[3][3..5],
        mini: true
      )
      attrs[:entry] = parts[4].to_f
      attrs[:take_profit] = data.match(/take profit: (\d{0,5}\.\d{0,5})/i)[1].to_f
      attrs[:stop_loss] = data.match(/stop loss: (\d{0,5}\.\d{0,5})/i)[1].to_f

      log.write(attrs.to_s)
      if attrs[:direction].blank? ||
          attrs[:pair].blank? || 
          attrs[:entry].blank?
        log.write("Skipped: Required argument(s) missing")
        next
      end

      signal = FxSignal.create!(attrs)
      order = signal.create_order
      order.ig_place_order
    end
  end

  private

    def messages
      Timeout::timeout(20) { service.fs }
    end

    def service
      @service ||= Gmail::Service.new
    end

    def expired?(message)
      time = message.payload.headers.find {|h| h.name == "Received" }.value.split(";").last.squish
      Time.parse(time).in_time_zone
    end

end
