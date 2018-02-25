require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.run_server = true
Capybara.current_driver = :selenium
# Capybara.current_driver = :poltergeist
# Capybara.javascript_driver = :poltergeist
# Capybara.app_host = "https://live-forex-signals.com"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {

  })
end

module Crawler
  class Base
    include Capybara::DSL

    def get_document(url, use_ssl = true, headers = {})
      uri = URI(url)

      Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl) do |http|
        request = Net::HTTP::Get.new uri

        res = http.request(request)

        if res.code.to_s != "200"
          raise "#{self.class} HTTP request expects status code 200. Got #{res.code}"
        end

        Nokogiri::HTML(res.body)
      end
    end

  end

end
