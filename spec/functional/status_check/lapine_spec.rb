require 'spec_helper'

RSpec.describe 'status check endpoint lapine publishing', type: :functional do
  let(:app) { Webhook::Web }
  let(:exchange) { Lapine.find_exchange('my.topic') }
  let!(:queue) { exchange.channel.queue.bind(exchange) }
  let(:hostname) { 'hostname' }
  let(:timestamp) { 1235467 }
  let(:status_message) {
    {
      service: 'webhook',
      hostname: hostname,
      timestamp: timestamp
    }
  }

  before do
    allow(Socket).to receive(:gethostname).and_return(hostname)
    # Time.now.utc.to_i
    allow(Time).to receive(:now) { double('time', utc: timestamp) }
  end

  it 'publishes a message with the appropriate contents' do
    get '/status_check', '', {}
    message = queue.messages.pop
    expect(message[0]).to eq(Oj.dump(status_message))
  end

end
