Raven.configure do |config|

  if Rails.env.production?
    config.dsn = ENV["SENTRY_DSN"]
  end

end
