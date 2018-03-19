require 'spec_helper'

RSpec.describe 'branch endpoint lapine publishing', type: :functional do
  let(:app) { Webhook::Web }
  let(:exchange) { Lapine.find_exchange('my.topic') }
  let(:body) { Oj.dump({ "id" => "1" }) }
  let!(:queue) { exchange.channel.queue.bind(exchange) }


  it 'enqueues open and install events to lapine' do
    post '/branch/events/install', body
    post '/branch/events/open', body
    post '/branch/events/shipment', body
    post '/branch/events/something', body
    expect(queue.message_count).to eq(2)
  end

  it 'uses request params as message contents' do
    post '/branch/events/install', body
    message = queue.messages.pop
    expect(message[0]).to eq(body)
  end

  it 'uses the webhook type as the routing key' do
    post '/branch/events/install', body
    message = queue.messages.pop
    expect(message[1]).to eq({routing_key: 'branch.events.install'})

    post '/branch/events/shipment', body
    message = queue.messages.pop
    expect(message[1]).to eq({routing_key: 'branch.events.shipment'})
  end
end
