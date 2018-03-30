module PiaFirst
  class GenerateSignalsFromEmailsJob < ApplicationJob
    queue_as :default

    def perform
      messages.messages.each do |m|
        if (email = Blacklist::Email.gmail.find_by(source_id: m.id))
          log.write("Skipped: #{m.id} exists in blacklist #{email.id}")
          next
        end

        if (fx_signal = FxSignal.find_by(source_secondary_id: m.id))
          log.write("Skipped: #{m.id} exists as FxSignal id #{fx_signal.id}")
          next
        end

        generator = ::FxSignal::Generator::Pia.new(m.id)
        generator.process!
      end
    end

    private

      def messages
        Timeout::timeout(20) { service.pia_first }
      end

      def service
        @service ||= Gmail::Service.new
      end

  end
end

