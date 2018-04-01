module PiaFirst
  class GenerateSignalsFromEmailsJob < ApplicationJob
    queue_as :default

    def perform
      messages.messages.each do |m|
        next if Blacklist::Email.gmail.find_by(source_id: m.id)
        next if FxSignal.find_by(source_secondary_id: m.id)

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


