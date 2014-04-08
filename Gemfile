source 'https://rubygems.org'
ruby '2.1.1'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.0'

# Need pg for heroku
# group :production, :staging do
#   gem "pg"
# end

# Use sqlite3 as the database for testing
group :test do
  gem 'sqlite3', "~> 1.3", :require => "sqlite3"
end

# Use mysql for dev and production
group :development, :production do
  gem "mysql2"
end

# Use Capistrano for deployment
group :development do
  gem 'capistrano'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler', '>=1.1.0'
  #gem "sqlite3"
end


# SQL query assistant
gem 'squeel'

gem 'rails_12factor', group: :production

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'execjs'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'haml'

gem 'haml-rails'

gem 'russian'

gem 'roadie'

gem "letter_opener", group: :development

# Paperclip - attachment manager
gem 'paperclip'

# Pageinate results
gem 'kaminari'

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0'

# Authentication system
gem 'devise'

# Authorization system
gem 'cancan'

# Create thumbnails
gem 'carrierwave'
gem 'mini_magick'

# Alternative server to WEBrick
gem 'puma'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'newrelic_rpm', "~> 3.7.3"

gem 'passenger'

gem 'ruby-progressbar'

# Command line prompt
gem 'highline', "~> 1.6"

gem 'whenever', :require => false

gem 'bootstrap-sass'
group :development do
  gem 'rails_layout'
end

gem "recaptcha"

gem 'tinymce-rails'