require 'sinatra/base'
require 'oj'
require 'webhook/settings'
require 'webhook/log_headers'
require 'webhook/metrics'
require 'webhook/status_check'
require 'webhook/shopify'
require 'webhook/sendgrid'
require 'webhook/sift_science'
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
      use Webhook::Sendgrid
      use Webhook::SiftScience
    end

    post '/stripe' do
      webhook = Oj.load(request.body.read)
      routing_key = ['stripe', webhook['type']].compact.join('.').force_encoding('UTF-8')
      Publisher::Stripe.new(webhook).publish(routing_key)
      Webhook::Metrics.instance.increment(routing_key)
      status 200
    end

    post %r{shopify/(?<wanelo_store_id>\w*)/(?<topic>\w*)/(?<action>\w*)} do
      webhook = Oj.load(request.body.read)
      routing_key = ['shopify', params['topic'], params['action']].join('.').force_encoding('UTF-8')
      webhook['wanelo_store_id'] = params['wanelo_store_id']
      Publisher::Shopify.new(webhook).publish(routing_key)
      Webhook::Metrics.instance.increment(routing_key)
      status 200
    end

    post %r{shopify/(?<topic>\w*)/(?<action>\w*)} do
      webhook = Oj.load(request.body.read)
      routing_key = ['shopify', params['topic'], params['action']].join('.').force_encoding('UTF-8')
      Publisher::Shopify.new(webhook).publish(routing_key)
      Webhook::Metrics.instance.increment(routing_key)
      status 200
    end

    post '/easypost' do
      webhook = Oj.load(request.body.read)
      routing_key = ['easypost', webhook['description']].compact.join('.').force_encoding('UTF-8')
      Publisher::EasyPost.new(webhook).publish(routing_key)
      Webhook::Metrics.instance.increment(routing_key)
      status 200
    end

    post '/sendgrid' do
      webhook = Oj.load(request.body.read)
      routing_key = 'sendgrid'
      Publisher::Sendgrid.new(webhook).publish(routing_key)
      Webhook::Metrics.instance.increment(routing_key)
      status 200
    end

    post '/sift_science/ban_user' do
      webhook = Oj.load(request.body.read)
      routing_key = 'sift_science.action.ban_user'
      Publisher::SiftScience.new(webhook).publish(routing_key)
      Webhook::Metrics.instance.increment(routing_key)
      status 200
    end

    post '/branch/events/:event' do
      if ['install', 'shipment'].include?(params[:event].to_s)
        webhook = Oj.load(request.body.read)
        routing_key = ['branch.events', params[:event]].join('.').force_encoding('UTF-8')
        Publisher::Branch.new(webhook).publish(routing_key)
        Webhook::Metrics.instance.increment(routing_key)
      end
      status 200
    end

    post '/desk/events/outbound_email' do
      webhook = Oj.load(request.body.read)
      routing_key = 'desk.events.outbound_email'
      Publisher::Desk.new(webhook).publish(routing_key)
      Webhook::Metrics.instance.increment(routing_key)
      status 200
    end

    get '/status' do
      '♥'
    end
  end
end
