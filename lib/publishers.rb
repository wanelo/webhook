require 'webhook/settings'
require 'publishers/stripe'
require 'publishers/shopify'

module Webhook
  module Publishers
    class << self
      def configure!
        Webhook::Settings.load!
        publisher_config = Webhook::Settings.publishers

        Lapine.add_connection 'rabbitmq', {
          host: publisher_config['connection']['host'],
          port: publisher_config['connection']['port'],
          user: publisher_config['connection']['username'],
          password: publisher_config['connection']['password'],
          vhost: publisher_config['connection']['vhost'],
          ssl: publisher_config['connection']['ssl']
        }

        exchange = publisher_config['exchange']
        Lapine.add_exchange exchange, {
          durable: true,
          connection: 'rabbitmq',
          type: 'topic'
        }

        Publisher::Stripe.exchange exchange
        Publisher::Shopify.exchange exchange
      end
    end
  end
end
