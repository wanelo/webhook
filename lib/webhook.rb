require 'sinatra/base'
require 'oj'
require 'webhook/settings'
require 'webhook/metrics'
require 'webhook/status_check'
require 'webhook/shopify'
require 'loginator/middleware/sinatra'
require 'publishers'
require 'multi_json'

MultiJson.use Oj
Oj.default_options = {:mode => :compat}

module Webhook
  class Web < Sinatra::Base
    configure do
      Publishers.configure!
      set :raise_errors, false
      set :show_exceptions, false
      set :root, File.expand_path('../..', __FILE__)
      use Webhook::StatusCheck
      logfile = ENV['LOGFILE'] || 'log/webhook.log'
      log = File.open(logfile, 'a')
      log.sync = true
      use Loginator::Middleware::Sinatra, log
      use Webhook::Shopify
    end

    post '/stripe' do
      webhook = Oj.load(request.body.read)
      routing_key = ['stripe', webhook['type']].compact.join('.')
      Publisher::Stripe.new(webhook).publish(routing_key)
      Webhook::Metrics.instance.increment(routing_key)
      status 200
    end

    post %r{shopify/(?<wanelo_store_id>\w*)/(?<topic>\w*)/(?<action>\w*)} do
      webhook = Oj.load(request.body.read)
      routing_key = ['shopify', params['topic'], params['action']].join('.')
      webhook['wanelo_store_id'] = params['wanelo_store_id']
      Publisher::Shopify.new(webhook).publish(routing_key)
      status 200
    end

    post %r{shopify/(?<topic>\w*)/(?<action>\w*)} do
      webhook = Oj.load(request.body.read)
      routing_key = ['shopify', params['topic'], params['action']].join('.')
      Publisher::Shopify.new(webhook).publish(routing_key)
      Webhook::Metrics.instance.increment(routing_key)
      status 200
    end
  end
end
