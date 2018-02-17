namespace :ig do
  task markets: :environment do
    Pair.delete_all

    service = IG::Service.new

    # service.watchlists

    body = service.watchlist(6770347)

    body["markets"].each do |market|
      Pair.find_or_create_by(ig_epic: market["epic"]) do |pair|
        pair.mini = true if market["instrumentName"].include?("Mini")
        
        pair.base = market["instrumentName"][0..2]
        pair.quote = market["instrumentName"][4..6]
      end
    end
  end

  task signals: :environment do
    service = IG::Service.new

    puts service.signals["signals"]["signals"]
  end
end
