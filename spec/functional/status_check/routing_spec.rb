require 'spec_helper'

RSpec.describe 'status check routing', type: :functional do
  let(:app) { Webhook::Web }

  it 'returns 200' do
    get '/status_check'
    expect(last_response.status).to eq(200)
  end
end
