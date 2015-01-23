require 'spec_helper'

RSpec.describe 'stripe endpoint routing', type: :functional do
  let(:app) { Webhook::Web }

  it 'returns 200 on post' do
    post '/stripe', '{}'
    expect(last_response.status).to eq(200)
  end

  it 'returns empty body post' do
    post '/stripe', '{}'
    expect(last_response.body).to eq('')
  end

  it 'returns 404 on get' do
    get '/stripe'
    expect(last_response.status).to eq(404)
  end
end
