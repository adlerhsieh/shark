task shark: :environment do
  Shark::Signal.delete_all

  service = Service.new
  gmail_ids = service.messages.messages.map {|m| m.id }.dup

  raw_signals = gmail_ids.map do |id|
    next if Shark::Signal.exists?(gmail_id: id)

    message = service.message(id)
    body = message.payload.parts.to_a.map {|b| b.body.data }.join("\n")
    body.include?("Signal") ? { id: id , body: body } : nil
  end.compact

  raw_signals.each do |hash|

    signal = if hash[:body].match(/New Signal!/) && hash[:body].match(/Buy stop/)
               "buy"
             elsif hash[:body].match(/New Signal!/) && hash[:body].match(/Buy stop/)
               "sell"
             elsif hash[:body].match(/Update Signal!/)
               "update"
             end

    pair = hash[:body].match(/\s\S{3}\\\S{3}/)

    Shark::Signal.create(
      gmail_id: hash[:id],
      signal: signal,
      raw: pair.to_s
    )
  end
end
