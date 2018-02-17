require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.run_server = false
# Capybara.current_driver = :selenium
Capybara.current_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.app_host = "https://deal.ig.com"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {

  })
end

module IG
  class Crawler
    include Capybara::DSL
  end

end




