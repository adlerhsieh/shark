require_relative 'boot'

require 'rails/all'

require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq-cron'
require 'sidekiq/cron/web'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Shark
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = "Sydney"
    config.active_record.default_timezone = :local

    Dir["#{Rails.root}/lib/**/*"].each do |file|
      require file if File.file?(file) && file =~ /\.rb$/
    end
    
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
    end

    config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_name_prefix = "shark.#{Rails.env}"
    config.active_job.queue_name_delimiter = '.'

    Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
  end
end
