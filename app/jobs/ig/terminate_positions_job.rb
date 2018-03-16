module IG
  class TerminatePositionsJob < ApplicationJob
    queue_as :default

    def perform
      positions.each do |position|
        if position.signal.terminated_at < Time.current
          IG::TerminatePositionJob.perform_later(position.id)
        end
      end
    end

    private

      def positions
        Position
          .includes(:signal)
          .joins(:signal)
          .where.not(fx_signals: { terminated_at: nil })
          .where.not(opened_at: nil)
          .where(closed_at: nil)
      end

  end
end
