require 'sinatra/base'
require 'oj'
require 'webhook/settings'
require 'webhook/status_check'
require 'publishers'
require 'pry'

Oj.default_options = {:mode => :compat}

module Webhook
  class Web < Sinatra::Base
    configure do
      Publishers.configure!
      set :dump_errors, false
      use Webhook::StatusCheck
    end

    post '/stripe' do
      webhook = Oj.load(request.body.read)
      routing_key = ['stripe', webhook['type']].compact.join('.')
      Publisher::Stripe.new(webhook).publish(routing_key)
      status 200
    end
  end
end
