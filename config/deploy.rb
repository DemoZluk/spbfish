require 'bundler/capistrano'

set :user, 'dezl'
set :domain, '192.168.56.2'
set :application, 'fmkt.tst'

# Using RVM
set :rvm_type, :user
set :rvm_ruby_string, 'ruby-2.0.0-p353'
require 'rvm/capistrano'

# file paths
set :repository, "#{user}@#{domain}:Git/#{application}.git"
set :deploy_to, "/home/#{user}/Workplace/www/#{application}"

role :app, domain
role :web, domain
role :db, domain, :primary => true

set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false
set :normalize_asset_timestamps, false
set :rails_env, :production

namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
    
  desc "reload the database with seed data"
  task :seed do
    deploy.migrations
    run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
  end
end
# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
