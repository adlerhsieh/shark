namespace :sidekiq do
  namespace :cron do
    task update: :destroy_all do
      Sidekiq::Cron::Job.create(
        name: "Update All Signals", 
        cron: "*/10 * * * *", 
        class: "UpdateAllAvailableSignalsJob"
      )

      Sidekiq::Cron::Job.create(
        name: "Convert Orders to Positions", 
        cron: "*/11 * * * *", 
        class: "IgConvertOrdersToPositionsJob"
      )

      Sidekiq::Cron::Job.create(
        name: "Close Positions", 
        cron: "*/12 * * * *", 
        class: "IgClosePositionsJob"
      )
    end

    task :destroy_all do
      Sidekiq::Cron::Job.destroy_all!
    end
  end
end
