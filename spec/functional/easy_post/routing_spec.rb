require 'spec_helper'

RSpec.describe 'easypost endpoint routing', type: :functional do
  let(:app) { Webhook::Web }

  it 'returns 200 on post' do
    post '/easypost', '{}'
    expect(last_response.status).to eq(200)
  end

  it 'returns empty body post' do
    post '/easypost', '{}'
    expect(last_response.body).to eq('')
  end

  it 'returns 404 on get' do
    get '/easypost'
    expect(last_response.status).to eq(404)
  end
end
