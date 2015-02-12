require 'spec_helper'

RSpec.describe 'shopify endpoint lapine publishing', type: :functional do
  let(:app) { Webhook::Web }
  let(:exchange) { Lapine.find_exchange('my.topic') }
  let(:body) { Oj.dump({ "id" => "1" }) }
  let(:secret) { 'secret' }
  let(:body_hmac) { Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret, body)).strip }
  let!(:queue) { exchange.channel.queue.bind(exchange) }


  before do
    allow_any_instance_of(Webhook::Shopify).to receive(:app_secret) { secret }
  end

  def rack_env(hmac)
    {
      'HTTP_X_SHOPIFY_HMAC_SHA256' => hmac,
      'Content-Type' => 'application/json',
    }
  end

  it 'publishes a message to lapine' do
    post '/shopify/orders/fulfilled', body, rack_env(body_hmac)
    expect(queue.message_count).to eq(1)
  end

  it 'uses request params as message contents' do
    post '/shopify/orders/fulfilled', body, rack_env(body_hmac)
    message = queue.messages.pop
    expect(message[0]).to eq(body)
  end

  it 'uses the webhook type as the routing key' do
    post '/shopify/orders/fulfilled', body, rack_env(body_hmac)
    message = queue.messages.pop
    expect(message[1]).to eq({routing_key: 'shopify.orders.fulfilled'})
  end
end
