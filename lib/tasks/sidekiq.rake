namespace :sidekiq do
  namespace :cron do
    task update: :destroy_all do
      Sidekiq::Cron::Job.create(
        name: "Update All Signals", 
        cron: "*/10 * * * *", 
        class: "UpdateAllAvailableSignalsJob"
      )

      # Sidekiq::Cron::Job.create(
      #   name: "Crawl love-forex-signals.com", 
      #   cron: "*/20 * * * *", 
      #   class: "CrawlerLiveForexSignalsJob"
      # )
    end

    task :destroy_all do
      Sidekiq::Cron::Job.destroy_all!
    end
  end
end
