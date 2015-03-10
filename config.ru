$:.unshift('./lib')
require 'webhook'
require 'newrelic_rpm'

NewRelic::Agent.manual_start if File.exist?('config/newrelic.yml')

run Webhook::Web
