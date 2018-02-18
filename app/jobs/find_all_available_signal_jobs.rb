class FindAllAvailableSignalsJob < ApplicationJob
  queue_as :default
 
  def perform
    FxSignal.recent.in_progress.each do |signal|
      SignalUpdateJob.perform_later(signal)
    end
  end

end

