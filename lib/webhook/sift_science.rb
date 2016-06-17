require 'openssl'

module Webhook

  class SiftScience
    attr_accessor :app

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'].match(/^\/sift_science/)
        unless authorized?(env)
          return [
            401, {}, ["The provided checksum #{provided_checksum(env)} didn't match #{expected_checksum(env)}\n"]
          ]
        end
      end
      @app.call(env)
    end

    private


    def authorized?(env)
      return true if ENV['SIFT_SCIENCE_VALIDATION_DISABLED']
      provided_checksum(env) == expected_checksum(env)
    end

    private

    def provided_checksum(env)
      env['HTTP_X_SIFT_SCIENCE_SIGNATURE'].to_s.chomp
    end

    def expected_checksum(env)
      req = Rack::Request.new(env)

      digest = OpenSSL::Digest.new('sha1')
      calculated_hmac = OpenSSL::HMAC.hexdigest(digest, secret_key, req.body.read).chomp
      req.body.rewind
      "sha1=#{calculated_hmac}"
    end

    def secret_key
      ENV['SIFT_SCIENCE_APP_SECRET']
    end
  end
end
