module IG
  class TerminatePositionsJob < ApplicationJob
    queue_as :default

    def perform
      positions.each do |position|
        if position.terminated_at < Time.current
          IG::TerminatePositionJob.perform_later(position.id)
        end
      end
    end

    private

      def positions
        Position
          .where.not(terminated_at: nil)
          .where.not(opened_at: nil)
          .where(closed_at: nil)
      end

  end
end
