# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever



set :environment, "development"
set :output, "log/cron.log"

every 1.hour do
  runner "DataGenerationWorker.perform_async(5, 20, 100)"
end

every 1.day, at: '4:30 am' do
  runner "DataGenerationWorker.perform_async(50, 200, 1000)"
end


# Run every 5 minutes
every 5.minutes do
  runner "DataGenerationWorker.perform_async(3, 10, 50)"
end