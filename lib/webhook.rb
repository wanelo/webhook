require 'sinatra/base'
require 'sinatra/namespace'
require 'oj'
require 'webhook/settings'
require 'webhook/logging'
require 'webhook/status_check'
require 'webhook/shopify'
require 'publishers'

Oj.default_options = {:mode => :compat}

module Webhook
  class Web < Sinatra::Base
    register Sinatra::Namespace

    configure do
      Publishers.configure!
      set :raise_errors, false
      set :show_exceptions, false
      set :root, File.expand_path('../..', __FILE__)
      use Webhook::StatusCheck
      logfile = ENV['LOGFILE'] || 'log/webhook.log'
      use Webhook::Logging, logfile
      use Webhook::Shopify
    end

    post '/stripe' do
      webhook = Oj.load(request.body.read)
      routing_key = ['stripe', webhook['type']].compact.join('.')
      Publisher::Stripe.new(webhook).publish(routing_key)
      status 200
    end

    %w(
      /shopify/orders/fulfilled
      /shopify/orders/cancelled
      /shopify/refunds/created
      /shopify/shop/updated
      /shopify/app/uninstalled
    ).each do |path|
      [:get, :post].each do |verb|
        self.send(verb, path) do
          Publisher::Shopify.new(request.params).publish(build_routing_key)
          status 200
        end
      end
    end

    private

    def build_routing_key
      request.path_info.split('/')[1..-1].join('.')
    end
  end
end

