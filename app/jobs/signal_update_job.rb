class SignalUpdateJob < ApplicationJob
  queue_as :default
 
  def perform
    FxSignal.update!
  end
end
