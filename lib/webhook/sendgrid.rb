require 'base64'
require 'openssl'
require 'webhook/metrics'

module Webhook
  # Sendgrid webhook middleware that returns 401 if Basic Auth
  #
  # NOTE: This will halt the callback chain
  class Sendgrid
    attr_accessor :app

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'].match(/^\/sendgrid/)
        unless authorized?(env)
          return [
            401,
            {'WWW-Authenticate' => %(Basic realm="Restricted Area")},
            ["Oops... we need your login name & password\n"]
          ]
        end
      end

      @app.call(env)
    end

    private

    def authorized?(env)
      auth = Rack::Auth::Basic::Request.new(env)
      auth.provided? && auth.basic? && auth.credentials && auth.credentials == [username, password]
    end

    def password
      ENV['SENDGRID_PASSWORD']
    end

    def username
      ENV['SENDGRID_USERNAME']
    end
  end
end
