module Dux

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
        data = message.payload.parts.first.body.data



      end
    end

    private

      def messages
        Timeout::timeout(20) { service.dux }
      end

      def service
        @service ||= Gmail::Service.new
      end

  end

end
