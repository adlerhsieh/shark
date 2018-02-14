task shark: :environment do
  Shark::Signal.delete_all

  service = Gmail::Service.new
  gmail_ids = service.shark.messages.map {|m| m.id }.dup

  raw_signals = gmail_ids.map do |id|
    next if Shark::Signal.exists?(gmail_id: id)

    message = service.message(id)
    subject = message.payload.headers.find {|h| h.name == "Subject" }.value
    body = message.payload.parts.to_a.map {|b| b.body.data }.join("\n")

    { id: id, subject: subject, body: body }
  end.compact

  raw_signals.each do |hash|
    puts "processing mail: #{hash[:id]}"

    signal = if hash[:body].match(/New Signal/i) && hash[:body].match(/buy stop/i)
               "buy"
             elsif hash[:body].match(/New Signal/i) && hash[:body].match(/sell stop/i)
               "sell"
             elsif hash[:body].match(/Update Signal/i) || hash[:body].match(/update order/i)
               "update"
             end

    pair = hash[:subject].match(/\s\S{3}\\\S{3}/).to_s

    pair_id = Pair.find_by(
      base: pair[0..2],
      quote: pair[4..6]
    )&.id

    Shark::Signal.create(
      gmail_id: hash[:id],
      signal: signal,
      raw: hash[:subject],
      pair_id: pair_id
    )
  end
end
