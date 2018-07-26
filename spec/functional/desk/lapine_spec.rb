require 'spec_helper'

RSpec.describe 'desk endpoint lapine publishing', type: :functional do
  let(:app) { Webhook::Web }
  let(:exchange) { Lapine.find_exchange('my.topic') }
  let(:body) { Oj.dump({ "id" => "1" }) }
  let!(:queue) { exchange.channel.queue.bind(exchange) }

  it 'uses request params as message contents' do
    post '/desk/events/outbound_email', body
    message = queue.messages.pop
    expect(message[0]).to eq(body)
    expect(message[1]).to eq({routing_key: 'desk.events.outbound_email'})
  end
end
