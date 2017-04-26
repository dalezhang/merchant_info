require File.expand_path('../boot', __FILE__)

# default
# require 'rails/all'

# without activerecord, for use mongodb
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_model/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MerchantInfo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # use mongodb
    config.generators do |g|
	  g.orm :mongoid
	end
  end
end
