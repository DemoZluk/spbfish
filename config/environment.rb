# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Fishmarkt::Application.initialize!

Fishmarkt::Application.configure do
	config.action_mailer.delivery_method = :smtp
	config.action_mailer.smtp_settings = {
		address: "smtp.spbfish.ru",
		port: 25,
		domain: "spbfish.ru",
		authentication: "plain",
		user_name: "mail@spbfish.ru",
		password: "alexis",
		enable_starttls_auto: true,
		openssl_verify_mode: 'none'
	}
end
