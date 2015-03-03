require 'spec_helper'

RSpec.describe 'stripe endpoint lapine publishing', type: :functional do
  let(:app) { Webhook::Web }
  let(:exchange) { Lapine.find_exchange('my.topic') }
  let!(:queue) { exchange.channel.queue.bind(exchange) }

  it 'publishes a message to lapine' do
    post '/stripe', '{"stuff":"awesome"}'
    expect(queue.message_count).to eq(1)
  end

  it 'uses the posted body as message content' do
    post '/stripe', '{"stuff":"awesome"}'
    message = queue.messages.pop
    expect(message[0]).to eq('{"stuff":"awesome"}')
  end

  it 'uses the webhook type as the routing key' do
    post '/stripe', '{"stuff":"awesome","type":"omg.lol.moneys"}'
    message = queue.messages.pop
    expect(message[1]).to eq({routing_key: 'stripe.omg.lol.moneys'})
  end

  it 'uses the webhook type as the routing key' do
    post '/stripe', '{"stuff":"awesome","type":"charge.dispute.created"}'
    message = queue.messages.pop
    expect(message[1]).to eq({routing_key: 'stripe.charge.dispute.created'})
  end
end
