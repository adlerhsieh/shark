class IgTerminatePositionsJob < ApplicationJob
  queue_as :default

  def perform
    positions.each do |position|
      if position.signal.terminated_at < Time.current
        IgTerminatePositionJob.perform_later(position.id)
      end
    end
  end

  private

    def positions
      Position.includes(:signal).joins(:signal).where.not(fx_signals: { terminated_at: nil })
    end

end
