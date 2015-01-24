module Webhook
  class StatusCheck

    attr_reader :app

    def initialize(app)
      @app = app
    end

    def call(env)
      path = env['PATH_INFO']
      if path.match(/^\/status_check/)
        [200, {}, []]
      else
        @app.call env
      end
    end
  end
end
