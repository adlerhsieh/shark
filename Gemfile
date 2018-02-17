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
gem 'jbuilder', '~> 2.5'
gem 'redis', '~> 3.0'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'dotenv-rails'
gem 'listen'
gem 'google-api-client'
gem 'pry'
gem 'bulk_insert'
gem 'nokogiri', '~> 1.8.1'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'turbolinks'
gem 'uglifier'

gem 'capistrano-rails', group: :development
gem 'capistrano-rbenv'
gem 'capistrano-bundler'

gem 'capybara', '~> 2.13'
gem 'poltergeist'
gem 'selenium-webdriver'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'seed_dump'
end

group :development do
end

