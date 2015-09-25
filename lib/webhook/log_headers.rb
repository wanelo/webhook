module Webhook
  class LogHeaders
    attr_reader :app

    def initialize(app)
      @app = app
      @logger = Logger.new(logfile)
    end

    def call(env)
      @logger.info "#{current_path(env)}: #{headers_for(env)}"
      app.call(env)
    end

    private

    def logfile
      "#{logdir}/headers.log"
    end

    def logdir
      File.dirname(ENV['LOGFILE'])
    end

    def headers_for(env)
      env.select { |header, value| header.start_with?('HTTP_') }
    end

    def current_path(env)
      env['REQUEST_PATH']
    end
  end
end
