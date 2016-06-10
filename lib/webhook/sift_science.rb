require 'openssl'

module Webhook

  class SiftScience
    attr_accessor :app

    def initialize(app)
      @app = app
    end

    def call(env)
      puts "DDDDD"

      if env['PATH_INFO'].match(/^\/sift_science/)
        unless authorized?(env)
          return [
            401, {}, ["The provided checksum didn't match\n"]
          ]
        end
      end

      @app.call(env)
    end

    private

    def authorized?(env)
      req = Rack::Request.new(env)

      digest  = OpenSSL::Digest.new('sha1')
      calculated_hmac = OpenSSL::HMAC.hexdigest(digest, secret_key , req.body.read)
      env['X-Sift-Science-Signature'] == "sha1=#{calculated_hmac}"
    end

    private

    def secret_key
      ENV['SIFT_SCIENCE_APP_SECRET']
    end

    def hash_function
      'sha1'
    end
  end
end
