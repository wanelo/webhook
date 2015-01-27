require 'base64'
require 'openssl'

module Webhook
  # Shopify webhook middleware that returns 401 if HMAC digest authentication is
  # unsuccessful.
  #
  # NOTE: This will halt the callback chain
  #
  # Shopify webhooks contin a HTTP_X_SHOPIFY_HMAC_SHA256 header that can be used to
  # verify the body of the request to ensure it came from Shopify using a shared
  # secret. See documentation here:
  # http://docs.shopify.com/api/webhooks/using-webhooks#verify-webhook
  class Shopify
    attr_reader :app

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'].match(/^\/shopify/)
        req = Rack::Request.new(env)
        hmac_header = env['HTTP_X_SHOPIFY_HMAC_SHA256']
        digest = OpenSSL::Digest.new('sha256')
        calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, app_secret, Oj.dump(req.params))).strip
        return [401, {}, []] if hmac_header != calculated_hmac
      end

      @app.call(env)
    end

    private

    # possess env variables SHOPIFY_APP_API_KEY and SHOPIFY_APP_SECRET
    def app_secret
      @app_secret ||= ENV['SHOPIFY_APP_SECRET']
    end

  end
end
