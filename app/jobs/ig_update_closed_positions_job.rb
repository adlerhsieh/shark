class IgUpdateClosedPositionsJob < ApplicationJob
  queue_as :default

  def perform(start_time = (Time.current - 1.day), end_time = Time.current)
    @start_time = start_time
    @end_time = end_time

    log.write("Getting all transactions from IG")
    log.write(transactions.to_json)

    transactions["transactions"].each do |transaction|
      pair_name = transaction["instrumentName"].match(/\S{3}\/\S{3}/).to_s
      mini = transaction["instrumentName"].match(/mini/i) ? true : false
      log.write("Processing: #{pair_name} #{"MINI" if mini}")
      pair = Pair.find_by(
        base: pair_name.split("/").first,
        quote: pair_name.split("/").last,
        mini: mini
      )

      if pair.present?
        log.write("Pair found: ##{pair.id}")
      else
        log.write("Pair not found")
        next
      end

      position = Position.find_by(
        entry: transaction["openLevel"],
        pair_id: pair.id
      )

      if position.present?
        log.write("Updating Position ##{position.id}")
        position.update(
          closed: transaction["closeLevel"],
          closed_at: Time.parse("#{transaction["dateUtc"]} UTC")
        )
      else
        log.write("Position not found")
      end
    end

  rescue ::IG::Service::NotAvailable => ex
    log.write("Error: #{ex}")
  rescue => ex
    log.error(ex)
  end
  
  private

    def transactions
      @transactions ||= service.transactions(@start_time, @end_time)
    end

    def service
      @service ||= IG::Service::Account.new
    end

end
