Raven.configure do |config|

  config.dsn = ENV["SENTRY_DSN"]
  config.environments = %w[production]

  config.silence_ready = true

  config.excluded_exceptions += [
    "ActionController::UnknownFormat"
  ]

end
