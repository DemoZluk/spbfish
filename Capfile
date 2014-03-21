# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#

set :default_shell, "/bin/bash --login"

require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'whenever/capistrano'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }

@user = "fish"
@server = "fishmarkt.ru"
@application = 'fishmarkt'

role :app, "#{@user}@#{@server}"

set :rvm_type, :system
set :rvm_ruby_version, '2.1.1'


task :precompile do
  on roles :app do
    info release_path
  end
end

task :test_path do
  on roles :app do
    info release_path
  end
end

task :chk_rvm do
  on roles :app, in: :sequence, wait: 5 do
    within release_path do
      execute :ls, '-l'
      execute "bundle", 'exec cap production rvm:check'
    end
  end
end