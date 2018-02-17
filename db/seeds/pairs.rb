Pair.delete_all

data = File.read("#{Rails.root}/lib/data/forex.json")
json = JSON.parse(data)

Pair.bulk_insert do |worker|
  json["results"]["markets"].each do |market|
    pair = market["underlyingName"]

    worker.add(
      base: pair[0..2],
      quote: pair[4..6],
      ig_epic: market["epic"],
      mini: market["name"].include?("Mini")
    )
  end
end
