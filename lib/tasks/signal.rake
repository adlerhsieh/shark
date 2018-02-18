namespace :signal do
  task update: :environment do
    FindAllAvailableSignalsJob.perform_now
  end
end
