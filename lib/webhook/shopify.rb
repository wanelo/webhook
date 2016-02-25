require 'base64'
require 'openssl'
require 'webhook/metrics'

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
        unless env['HTTP_X_SHOPIFY_HMAC_SHA256']
          Webhook::Metrics.instance.increment('shopify.hmac_missing')
          return [401, {}, []]
        end

        req = Rack::Request.new(env)
        hmac_header = env['HTTP_X_SHOPIFY_HMAC_SHA256'].chomp

        matches = matching_hmac(hmac_header, req)
        req.body.rewind

        unless matches
          Webhook::Metrics.instance.increment('shopify.hmac_mismatch')
          return [401, {}, []]
        end
      end

      @app.call(env)
    end

    private

    def matching_hmac(header, req)
      digest = OpenSSL::Digest.new('sha256')
      body = req.body.read
      [app_secret, channel_dev_app_secret, channel_app_secret].find do |key|
        key && (Base64.encode64(OpenSSL::HMAC.digest(digest, key, body)).chomp == header)
      end != nil
    end

    def app_secret
      ENV['SHOPIFY_APP_SECRET']
    end

    # The development app will need production webhooks for testing
    def channel_dev_app_secret
      ENV['SHOPIFY_CHANNEL_DEV_APP_SECRET']
    end

    # The development app will need production webhooks for testing
    def channel_app_secret
      ENV['SHOPIFY_CHANNEL_APP_SECRET']
    end

  end
end
