require 'spec_helper'

RSpec.describe 'easy post endpoint lapine publishing', type: :functional do
  let(:app) { Webhook::Web }
  let(:exchange) { Lapine.find_exchange('my.topic') }
  let!(:queue) { exchange.channel.queue.bind(exchange) }

  it 'publishes a message to lapine' do
    post '/easypost', '{"stuff":"awesome"}'
    expect(queue.message_count).to eq(1)
  end

  it 'uses the posted body as message content' do
    post '/easypost', '{"stuff":"awesome"}'
    message = queue.messages.pop
    expect(message[0]).to eq('{"stuff":"awesome"}')
  end

  it 'uses the webhook description as the routing key' do
    post '/easypost', '{"stuff":"awesome","type":"omg.lol.moneys","description":"harry.butts"}'
    message = queue.messages.pop
    expect(message[1]).to eq({routing_key: 'easypost.harry.butts'})
  end
end
