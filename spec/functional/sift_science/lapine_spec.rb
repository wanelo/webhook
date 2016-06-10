RSpec.describe 'sift_science endpoint lapine publishing', type: :functional do
  let(:app) { Webhook::Web }
  let(:exchange) { Lapine.find_exchange('my.topic') }
  let!(:queue) { exchange.channel.queue.bind(exchange) }

  let(:body) { '{"id":"e2260152130a5844d9b38e2261eaea827ffffeaaca739bff:ban_user_1","action":{"id":"ban_user_1","href":"https://api3.siftscience.com/v3/accounts/52dee51afe6b7ce6b0000047/actions/ban_user_1"},"entity":{"id":"19884820","href":"https://api3.siftscience.com/v3/accounts/52dee51afe6b7ce6b0000047/users/19884820"},"time":1465482241024,"triggers":[{"type":"formula","trigger":{"id":"575076cee4b094a673cf3a3c","href":"https://api3.siftscience.com/v3/accounts/52dee51afe6b7ce6b0000047/formulas/575076cee4b094a673cf3a3c"}}]}' }
  let(:headers) { {'X-Sift-Science-Signature' => 'sha1=f6ad932ba8057d11fe1b6c3e8e4cf8b1b6770139'} }
  let(:secret) { 'abcdefghijkl1234' }

  before do
    allow(ENV).to receive(:[]).with ('SIFT_SCIENCE_APP_SECRET') { secret }
  end


  it 'publishes a message to lapine' do
    post '/sift_science', body, headers
    expect(queue.message_count).to eq(1)
  end

  it 'uses the posted body as message content' do
    post '/sift_science', body, headers
    message = queue.messages.pop
    expect(message[0]).to eq(body)
  end

  it 'uses the webhook description as the routing key' do
    post '/sift_science', body, headers
    message = queue.messages.pop
    expect(message[1]).to eq({routing_key: 'sift_science.action.ban_user_1'})
  end
end
