# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Spbfish::Application.initialize!

APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")
