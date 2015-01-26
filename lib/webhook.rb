require 'sinatra/base'
require 'oj'
require 'webhook/settings'
require 'webhook/logging'
require 'webhook/status_check'
require 'publishers'

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
      use Webhook::Logging, logfile
    end

    post '/stripe' do
      webhook = Oj.load(request.body.read)
      routing_key = ['stripe', webhook['type']].compact.join('.')
      Publisher::Stripe.new(webhook).publish(routing_key)
      status 200
    end
  end
end
