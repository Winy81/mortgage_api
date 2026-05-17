set :environment, "development"
set :output, "log/cron.log"

every 5.minutes do
  runner "MortgageProcessStarterJob.perform_later"
end

every 10.minutes do
  runner "PropertyValuationRequestJob.perform_later"
end

every 15.minutes do
  runner "PropertyValuationResultFetcherJob.perform_later"
end
