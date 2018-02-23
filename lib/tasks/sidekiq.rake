namespace :sidekiq do
  namespace :cron do
    task :update do
      unless Sidekiq::Cron::Job.find("Update All Signals")
        Sidekiq::Cron::Job.create(
          name: "Update All Signals", 
          cron: "*/10 * * * *", 
          class: "UpdateAllAvailableSignalsJob"
        )
      end
    end

    task :destroy_all do
      Sidekiq::Cron::Job.destroy_all!
    end
  end
end
