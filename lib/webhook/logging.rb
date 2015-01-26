require 'oj'
require 'securerandom'

module Webhook
  module Jsonable
    def to_json
      Oj.dump(
        {}.tap do |hsh|
          self.each_pair do |k, v|
            hsh[k] = v
          end
        end
      )
    end

    alias :to_s :to_json
  end

  class Request < Struct.new(:id, :timestamp, :path, :body); include Jsonable end
  class Response < Struct.new(:id, :timestamp, :path, :status, :response); include Jsonable end

  class Logging

    attr_reader :app, :logfile

    def initialize(app, path)
      @app = app
      @logfile = File.open(path, 'a')
      @logfile.sync = true
    end

    def call(env)
      env['X-REQUEST-UUID'] ||= SecureRandom.uuid
      req = Rack::Request.new(env)
      logfile.puts Request.new(env['X-REQUEST-UUID'], Time.now.utc.to_s, env['REQUEST_PATH'], req.body.read)
      req.body.rewind
      @app.call(env).tap do |status, headers, body|
        logfile.puts Response.new(env['X-REQUEST-UUID'], Time.now.utc.to_s, env['REQUEST_PATH'], status, body)
      end
    end
  end
end
