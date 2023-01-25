
set :output, "log/cron_log.log"

every 15.minutes do
  rake "sheet:stream"
end