class Lfs::CrawlAllJob < ApplicationJob
  queue_as :default

  def perform
    crawler = Crawler::LiveForexSignals.new(
      app_host: Crawler::LiveForexSignals::HOST
    )

    crawler.access
    crawler.process!
    
  rescue => ex
    log.error(ex)
  end


end
