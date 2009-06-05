# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
#ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Authorization plugin for role based access control
# You can override default authorization system constants here.

# NOTE : If you use modular controllers like '/admin/products' be sure
# to redirect to something like '/sessions' controller (with a leading slash)
# as shown in the example below or you will not get redirected properly
#
# This can be set to a hash or to an explicit path like '/login'
#
LOGIN_REQUIRED_REDIRECTION = { :controller => '/sessions', :action => 'new' }
PERMISSION_DENIED_REDIRECTION = { :controller => '/home', :action => 'index' }

# The method your auth scheme uses to store the location to redirect back to
STORE_LOCATION_METHOD = :store_location

Rails::Initializer.run do |config|

	# Uncomment if you want to use the default blank views
	# config.view_path = 'app/views_blank'
	
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
	# For BackgroundRb
	config.gem 'chronic', :version => '>=0.2.3', :lib => 'chronic'
#		config.gem 'hoe', :version => '>=1.2.1', :lib => 'hoe'
#			config.gem 'rubyforge', :version => '>=1.0.1'
#			config.gem 'rake', :version => '>=0.8.3'
	config.gem 'packet', :version => '>=0.1.14', :lib => 'packet'
	config.gem 'rfeedparser', :version => '=0.9.951', :lib => 'rfeedparser'
#		config.gem 'rchardet', :version => '>=1.1'
#		config.gem 'hpricot', :version => '>=0.6'
#		config.gem 'character-encodings', :version => '>=0.2.0', :lib => false
#		config.gem 'htmltools', :version => '>=1.10', :lib => false
#		config.gem 'htmlentities', :version => '>=4.0.0'
#		config.gem 'mongrel', :version => '>=1.0.1'
#		config.gem 'addressable', :version => '>=1.0.4', :lib => false
	# for Savage Beast forum

	config.gem 'fastercsv', :version => '>=1.4.0', :lib => 'fastercsv'
	config.gem 'RedCloth', :version => '>=4.0.0', :lib => 'redcloth'
	config.gem 'rmagick', :version => '>=2.9.1', :lib => 'RMagick'

	

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
	#config.plugin_paths += %W( #{RAILS_ROOT}/blank_modules )
	#config.plugin_paths += %W( #{RAILS_ROOT}/blank_modules/aep_beast/plugins )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_trunk_session',
    :secret      => '5a935d96b6d595c4071f7daebc87576f6b96c0fa3952943872d5932a7f3f42a1c5b9364d7397eb3fe00829ec6408043cf90ad002dbfa281a37d75e41b295dedc'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.action_controller.session_store = :active_record_store

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # RESTful authentification observer
  config.active_record.observers = :user_observer

	# Need the production_log_analyze gem
	# Use for example : pl_analyze log/production.log -e recipient@example.com
	# TODO special logs files for pl_analyze
	require 'hodel_3000_compliant_logger'
	config.logger = Hodel3000CompliantLogger.new(config.log_path)
	
end