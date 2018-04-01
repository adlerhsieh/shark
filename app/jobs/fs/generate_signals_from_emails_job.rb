module Fs
  class GenerateSignalsFromEmailsJob < ApplicationJob
    queue_as :default

    def perform
      messages.messages.each do |m|
        next if FxSignal.find_by(source_secondary_id: m.id)

        generator = FxSignal::Generator::Fs.new(m.id)
        generator.process!
      end
    end

    private

      def messages
        Timeout::timeout(20) { service.fs }
      end

      def service
        @service ||= Gmail::Service.new
      end

  end
end
