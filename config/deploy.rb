# config valid only for Capistrano 3.1
lock '3.1.0'

user = 'fish'
domain = 'test.spbfish.ru'
application = 'spbfish.ru'

# set :user, @user
# set :domain, @server
# set :application, @application

set :repo_url, "#{@user}@#{@server}:www/git/#{@application}.git"
set :deploy_to, "/home/#{@user}/www/#{@application}"

# set :rvm_type, :user
# set :rvm_ruby_string, 'ruby-2.0.0-p356'
# require 'rvm1/capistrano3'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, "/home/#{user}/Workplace/www/#{application}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# before 'deploy', 'rvm1:install:rvm'   # install/update RVM
# before 'deploy', 'rvm1:install:ruby'  # install/update Ruby

# namespace :deploy do
#   desc "Setting up database"
#   task :setup do
#     on roles :app do
#       execute :bundle, "exec rake db:setup"
#     end
#   end

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       # Your restart mechanism here, for example:
#       # execute :touch, release_path.join('tmp/restart.txt')
#     end
#   end

#   after :publishing, :restart

#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end

# end

# before "deploy:setup", "db:configure"

# namespace :db do
#   task :configure do
#     on roles :app do
#       def create_db
#         info "Create database yaml in shared path"
#           database_username = HighLine.ask("User name(empty = root): ", String) {|q| q.default = 'root'}

#           database_password = HighLine.ask("Database Password: ", String) {|q| q.echo = '*'}

#           db_config = <<-EOF
#             base: &base
#               adapter: mysql2
#               encoding: utf8
#               reconnect: false
#               pool: 5
#               username: #{database_username}
#               password: #{database_password}

#             development:
#               database: #{@application}_development
#               <<: *base

#             test:
#               database: #{@application}_test
#               <<: *base

#             production:
#               database: #{@application}_production
#               <<: *base
#           EOF

#           execute :mkdir, "-p #{shared_path}/config"
#           execute :touch, "#{shared_path}/config/database.yml"
#           put db_config, "#{shared_path}/config/database.yml"
          
#           info "Make symlink for database yaml"

#           execute :ln, "-nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
#       end
         
#       db = "#{shared_path}/config/database.yml"
#       if test("[ -f #{db} ]")
#         q = HighLine.ask("database.yml already exists, overwrite?[y/n] ", String){|q| q.default = ''}
#         if q == 'y'
#           create_db
#         else
#           info "Skippng..."
#         end
#       else
#         create_db
#       end
#     end
#   end
# end