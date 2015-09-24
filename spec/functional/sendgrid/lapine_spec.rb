require 'spec_helper'

RSpec.describe 'sendgrid endpoint lapine publishing', type: :functional do
  let(:app) { Webhook::Web }
  let(:exchange) { Lapine.find_exchange('my.topic') }
  let!(:queue) { exchange.channel.queue.bind(exchange) }
  let(:username) { 'foo' }
  let(:password) { 'bar' }

  before {
    allow_any_instance_of(Webhook::Sendgrid).to receive(:username) { username }
    allow_any_instance_of(Webhook::Sendgrid).to receive(:password) { password }
    basic_authorize(username, password)
  }

  it 'publishes a message to lapine' do
    post '/sendgrid', '{"stuff":"awesome"}'
    expect(queue.message_count).to eq(1)
  end

  it 'uses the posted body as message content' do
    post '/sendgrid', '{"stuff":"awesome"}'
    message = queue.messages.pop
    expect(message[0]).to eq('{"stuff":"awesome"}')
  end

  it 'uses sendgrid as the routing key' do
    post '/sendgrid', '{"stuff":"awesome","type":"omg.lol.moneys"}'
    message = queue.messages.pop
    expect(message[1]).to eq({routing_key: 'sendgrid'})
  end
end
