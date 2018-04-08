module FxPremiere
  class GenerateSignalsFromEmailsJob < ApplicationJob
    queue_as :default

    def perform
      messages.messages.each do |m|
        next if FxSignal.find_by(source_secondary_id: m.id)

        generator = ::FxSignal::Generator::Premiere.new(m.id)
        generator.process!
      end
    end

    private

      def messages
        Timeout.timeout(20) { service.fx_premiere }
      end

      def service
        @service ||= Gmail::Service.new
      end

  end
end

