module IG
  class UpdateClosedPositionsJob < ApplicationJob
    queue_as :default

    def perform(start_time = (Time.current - 4.hours), end_time = Time.current)
      @start_time = start_time
      @end_time = end_time

      # log.write("Getting all transactions from IG")

      transactions["transactions"].each do |transaction|
        instrument = transaction["instrumentName"]
        pair_name = instrument.match(/\S{3}\/\S{3}/).to_s
        mini = transaction["instrumentName"].match(/mini/i) ? true : false

        # Exception: XAU
        if pair_name.blank?
          pair_name = "XAU/USD" if instrument.downcase.include?("spot gold")
            
          if instrument.downcase.include?("a$1")
            pair_name = "XAU/AUD"
            mini = true
          end
          if instrument.downcase.include?("a$10")
            mini = false
          end
        end

        # log.write("Processing: #{pair_name} #{"MINI" if mini}")
        pl_info = transaction["profitAndLoss"].match(/^(\S*)\$(.*)$/)
        currency = {
          "A" => "AUD"
        }[pl_info[1]]
        pl = pl_info[2]

        pair = Pair.find_by(
          base: pair_name.split("/").first,
          quote: pair_name.split("/").last,
          mini: mini
        )

        if pair.present?
          # log.write("Pair found: ##{pair.id}")
        else
          # log.write("Pair not found")
          next
        end

        position = Position.find_by(
          entry: transaction["openLevel"],
          pair_id: pair.id,
          closed_at: nil
        )

        if position.present?
          next if position.closed && position.closed_at
          # log.write("Updating Position ##{position.id}")
          position.update(
            closed: transaction["closeLevel"],
            closed_at: Time.parse("#{transaction["dateUtc"]} UTC"),
            pl: pl,
            currency: currency
          )
        else
          # log.write("Position not found")
        end
      end

    rescue ::IG::Service::NotAvailable => ex
      log.write("Error: #{ex}")
    rescue => ex
      log.write(transactions.to_json)
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
end
