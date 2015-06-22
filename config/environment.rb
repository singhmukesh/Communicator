# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Load env_vars file for development
env_vars = File.join(Rails.root, '/config/env_vars.rb')
load(env_vars) if File.exists?(env_vars)

# Password for the admin user
ADMIN_PASSWORD = ENV['ADMIN_PASSWORD'] || "whatUsee"

# Client ID and Secret
RTCC_CLIENT_ID = ENV['RTCC_CLIENT_ID']
RTCC_CLIENT_SECRET = ENV['RTCC_CLIENT_SECRET']

# For the front end
RTCC_APP_ID = ENV['RTCC_APP_ID']

# RTCC Domain Identifier ("yourdomain.com")
RTCC_DOMAIN_IDENTIFIER = ENV['RTCC_DOMAIN_IDENTIFIER']

# For the cloud recorder
CLOUDRECORDER_TOKEN = ENV['CLOUDRECORDER_TOKEN']

# Initialize the Rails application.
Simplelogin::Application.initialize!

