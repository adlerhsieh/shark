source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.3'
gem 'mysql2'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'therubyracer', platforms: :ruby
gem 'devise'
gem 'jbuilder', '~> 2.5'
gem 'redis', '~> 3.0'
gem 'sidekiq'
gem "sidekiq-cron", "~> 0.6.3"
gem 'dotenv-rails'
gem 'listen'
gem 'google-api-client'
gem 'pry-rails'
gem 'bulk_insert'
gem 'nokogiri', '~> 1.8.1'
gem 'turbolinks'
gem 'uglifier'
gem 'slack-notifier'
gem 'capistrano-rails', group: :development
gem 'capistrano-rbenv'
gem 'capistrano-bundler'
gem 'capybara', '~> 2.13'
gem 'poltergeist'
gem 'selenium-webdriver'
gem 'gon'
gem "sentry-raven"

gem "eventmachine"
gem "em-synchrony"
gem "oj"
gem "telegram-rb", require: "telegram"

group :development, :test do
  gem 'simplecov', require: false
  gem 'codacy-coverage', :require => false

  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'database_cleaner'
  gem 'seed_dump'
  gem 'spring'
end
