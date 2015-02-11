require 'socket'
require 'publishers/status'

module Webhook
  class StatusCheck

    attr_reader :app

    def initialize(app)
      @app = app
    end

    def call(env)
      path = env['PATH_INFO']
      if path.match(/^\/status_check/)
        begin
          Publisher::Status.new(status).publish('services.heartbeat')
          [200, {}, []]
        rescue StandardError => e
          [503, {}, []]
        end
      else
        @app.call env
      end
    end

    def status
      {
        service: 'webhook',
        hostname: Socket.gethostname,
        timestamp: Time.now.utc.to_i
      }
    end
  end
end
