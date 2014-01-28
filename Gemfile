source 'https://rubygems.org'
ruby '2.0.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Need pg for heroku
group :production, :staging do
  gem "pg"
end

group :test do
  gem 'sqlite3'
end

# Use sqlite3 as the database for dev and test
group :development do
  gem "mysql2"
  #gem "sqlite3", "~> 1.3.0", :require => "sqlite3"
end

# SQL query assistant
gem 'squeel'

gem 'rails_12factor', group: :production

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'execjs'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

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
gem 'bcrypt-ruby', '~> 3.0.0'

# Authentication system
gem 'devise'

# Create thumbnails
gem 'carrierwave'
gem 'mini_magick'

# Alternative server to WEBrick
gem 'puma'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano', '~> 3.1.0'
gem 'capistrano-rvm'
gem 'capistrano-bundler', '>=1.1.0'

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'newrelic_rpm'

gem 'passenger'

gem 'ruby-progressbar'