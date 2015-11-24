require 'webhook/settings'
require 'publishers/stripe'
require 'publishers/shopify'
require 'publishers/sendgrid'
require 'publishers/easy_post'
require 'publishers/status'

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
          ssl: publisher_config['connection']['ssl'],
          heartbeat: 10
        }

        exchange = publisher_config['exchange']
        Lapine.add_exchange exchange, {
          durable: true,
          connection: 'rabbitmq',
          type: 'topic'
        }

        Publisher::Sendgrid.exchange exchange
        Publisher::Stripe.exchange exchange
        Publisher::Shopify.exchange exchange
        Publisher::EasyPost.exchange exchange
        Publisher::Status.exchange exchange
      end
    end
  end
end
