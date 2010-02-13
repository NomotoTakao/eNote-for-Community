# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_enote_session',
  :cookie_only => false,
  :secret      => '93e535e83dddec7df9cf3ca8ac930b7b1a58ebae689c4b484feea0780734c0bec4e8d7262ce8cf8a5fbda56820cdf0bc0b32154773a27a737c1088bcfdcaf6f0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store

