namespace :sidekiq do
  namespace :cron do
    task :create do
      unless Sidekiq::Cron::Job.find("Signal Update")
        Sidekiq::Cron::Job.create(
          name: "Signal Update", 
          cron: "0 */2 * * *", 
          class: "SignalUpdateJob"
        )
      end
    end

    task :destroy_all do
      Sidekiq::Cron::Job.destroy_all!
    end
  end
end
