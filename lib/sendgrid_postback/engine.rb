# http://www.engineyard.com/blog/2010/extending-rails-3-with-railties/

require 'rails'

module SendgridPostback
  class Engine < ::Rails::Engine

    initializer :logger do
      config.logger = Rails.logger
    end

    config.after_initialize do
      MailInterceptor.install unless config.disable_interceptor
    end

  end
end
