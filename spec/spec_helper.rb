require 'rack/test'
require 'webhook'
require 'pry'
require 'lapine/test/rspec_helper'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include Lapine::Test::RSpecHelper
  config.before(:each) do |example|
    Lapine::Test::RSpecHelper.setup(example)
  end

  config.after(:each) do
    Lapine::Test::RSpecHelper.teardown
  end

  config.include Rack::Test::Methods, type: :functional

  config.before :each, type: :integration do
    @server ||= Capybara::Server.new(Webhook::Web).tap do |server|
      server.app.logging = false
      server.boot
    end
  end
end
