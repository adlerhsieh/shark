module Crawler

  # For solving NameError
  class Base; end

  class Dux < Crawler::Base

    HOST = "https://www.duxforex.com"

    attr_accessor :document

    def login
      visit("/about")
      find("span#btl-panel-login").click
      fill_in "username", with: ENV["DUX_USERNAME"]
      fill_in "password", with: ENV["DUX_PASSWORD"]
      check "remember"
      # click_button "Log in"
      find(".login-button").click
    end

    def get(url)
      # set_default_headers! 
      visit(url)
      sleep(2)
      @document = Nokogiri::HTML(page.body)
    end 

    def access
      set_default_headers!
      get("/forex-signals")
      if @document.css(".shout-header").blank?
        login
        get("/forex-signals")
      end
    end

    def set_default_headers!
      page.driver.headers = {}
      page.driver.add_headers(
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        # "Accept-Encoding" => "gzip, deflate, br",
        "Accept-Language" => "zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7,zh-CN;q=0.6",
        "Cache-Control" => "no-cache",
        "Connection" => "keep-alive",
        "Host" => "www.duxforex.com",
        "Pragma" => "no-cache",
        "Referer" => "https://www.duxforex.com",
        "Upgrade-Insecure-Requests" => "1",
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
      )
    end


  end

end
