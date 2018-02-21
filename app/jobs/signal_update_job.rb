class SignalUpdateJob < ApplicationJob
  queue_as :default
 
  def perform(signal)
    price_list = IG::PriceCollect.new(signal).collect
    IG::SignalUpdate.new(price_list, signal).update!
  end

end
