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
# 
set :output, 'log/cron_jobs.log'
set :whenever_identifier, "spbfish"

env :PATH, ENV['PATH']
env :GEM_HOME, ENV['GEM_HOME']


every :day do
  rake 'destroy_abandoned_carts'
end

every :day, at: '2:00am' do
  runner 'Product.get_webdata'
end