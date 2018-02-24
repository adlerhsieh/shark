$slack = Slack::Notifier.new ENV["SLACK_WEBHOOK_URL"] do
  defaults username: "notifier"
end
