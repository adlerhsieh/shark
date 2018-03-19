module Arrow
  class GenerateSignalsFromEmailsJob < ApplicationJob
    queue_as :default

    def perform
      messages.messages.each do |m|
        if (fx_signal = FxSignal.find_by(source_secondary_id: m.id))
          log.write("Skipped: #{m.id} exists as FxSignal id #{fx_signal.id}")
          next
        end

        message = service.message(m.id)

        attrs = {
          source_secondary_id: m.id,
          expired_at: Time.current + 3.days
        }
        data    = message.payload.parts.first.body.data

        unless data.include?("Currency Pair")
          log.write("Skipped: not a signal email")
          next
        end

        pair = data.match(/Currency Pair[ ]?(\S{3}\/\S{3})/i)[1]
        attrs[:pair] = Pair.find_by(
          base: pair.split("/").first,
          quote: pair.split("/").last,
          mini: true
        )
        attrs[:source] = Source.find_or_create_by(name: "arrowpips.com") { |source| source.active = true } 
        attrs[:entry] = data.match(/Entry Point[ ]?(\d{1,5}\.\d{1,5})/i)[1]
        attrs[:stop_loss] = data.match(/Stop Loss[ ]?(\d{1,5}\.\d{1,5})/i)[1]
        attrs[:take_profit] = data.match(/Take profit 1[ ]?(\d{1,5}\.\d{1,5}|\d{1,5}[ ]?Pips)/i)[1]

        if attrs[:take_profit].downcase.include?("pips")
          attrs[:take_profit] = attrs[:entry].to_f + (0.0001 * attrs[:take_profit].to_i)
        end

        attrs[:direction] = if attrs[:entry].to_f > attrs[:stop_loss].to_f
                              "buy"
                            else
                              "sell"
                            end

        log.write(attrs.to_s)
        if attrs[:direction].blank? ||
            attrs[:pair].blank? || 
            attrs[:entry].blank?
          log.write("Skipped: Required argument(s) missing")
          next
        end

        signal = FxSignal.create!(attrs)

        if signal.take_profit == 0.0 || signal.stop_loss == 0.0
          signal.update(expired_at: nil)
          log.write("Skipped: Missing TP or SL")
          next
        end

        order = signal.create_order
        order.ig_place_order
      end
    end

    private

      def messages
        Timeout::timeout(20) { service.arrow }
      end

      def service
        @service ||= Gmail::Service.new
      end

  end
end
