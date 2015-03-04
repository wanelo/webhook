require 'singleton'
require 'statsd'

module Webhook
  # Fake Statsd if we do not have metrics enabled
  class MockStatsd
    def gauge(_name, _value); end
    def count(_name, _count = 1); end
  end

  # Wrapper for Statsd metrics
  class Metrics
    include Singleton
    attr_reader :statsd

    def initialize
      @statsd = enabled? ? Statsd.new(host, port) : MockStatsd.new
    end

    def gauge(name, value)
      statsd.gauge("webhook.#{name}", value)
    end

    def increment(name, count = 1)
      statsd.count("webhook.#{name}_count", count)
    end

    def enabled?
      host && port
    end

    def host
      ENV['STATSD_HOST']
    end

    def port
      ENV['STATSD_PORT']
    end
  end
end
