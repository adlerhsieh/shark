class SignalUpdateJob < ApplicationJob
  queue_as :default
 
  def perform(signal)
    IG::PriceUpdate.new(price_list(signal), signal).update!
  end

  private

    def service
      @service ||= IG::Service.new
    end

    def price_list(signal)
      service.price(
        signal.pair.ig_epic,
        signal.created_at.strftime("%Y-%m-%d"),
        (signal.created_at + 1.day).strftime("%Y-%m-%d")
      )
    end

end
