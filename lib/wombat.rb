require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.run_server = true
# Capybara.current_driver = :selenium
Capybara.current_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
# Capybara.app_host = "https://live-forex-signals.com"
Capybara.default_max_wait_time = 20

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    js_errors: false
  )
end

module Wombat

  class Server
    include Capybara::DSL
    
    attr_accessor :document

    def initialize
      Capybara.app_host = "https://web.telegram.org"
    end

    def run
      set_default_headers!

      begin
        visit("/")
      rescue Capybara::Poltergeist::StatusFailError => ex
        puts ex.message
        puts "TIMEOUT! Trying again."
        visit("/")
      end

      find('div[ng-bind="credentials.phone_country_name"]').click
      all("span", class: "countries_modal_country_name", text: "Australia").last.click
      fill_in "phone_number", with: ENV["TELEGRAM_PHONE_NUMBER"]
      find("my-i18n", text: "Next").click
      find("span", text: "OK").click
      # puts "Code: "
      # code = gets
      # code.squish!
      fill_in "phone_code", with: "32648"

      @document = Nokogiri::HTML(page.body)
    end

    def set_default_headers!
      page.driver.headers = {}
      page.driver.add_headers(
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        # "Accept-Encoding" => "gzip, deflate, br",
        "Accept-Language" => "zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7,zh-CN;q=0.6",
        "Cache-Control" => "no-cache",
        "Connection" => "keep-alive",
        "Pragma" => "no-cache",
        "Upgrade-Insecure-Requests" => "1",
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
      )
    end

  end

end
