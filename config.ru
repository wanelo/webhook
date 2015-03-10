$:.unshift('./lib')
require 'webhook'
require 'newrelic_rpm'

NewRelic::Agent.manual_start if File.exist?(File.expand_path('../config/newrelic.yml', __FILE__))

run Webhook::Web
