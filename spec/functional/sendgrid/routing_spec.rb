require 'spec_helper'

RSpec.describe 'sendgrid endpoint routing', type: :functional do
  let(:app) { Webhook::Web }
  let(:username) { 'foo' }
  let(:password) { 'bar' }

  before {
    allow_any_instance_of(Webhook::Sendgrid).to receive(:username) { username }
    allow_any_instance_of(Webhook::Sendgrid).to receive(:password) { password }
    header('Authorization', nil)
  }

  context 'with correct auth' do
    before do
      basic_authorize(username, password)
    end

    it 'returns 200 on post' do
      post '/sendgrid', '{}'
      expect(last_response.status).to eq(200)
    end

    it 'returns empty body post' do
      post '/sendgrid', '{}'
      expect(last_response.body).to eq('')
    end

    it 'returns 404 on get' do
      get '/sendgrid'
      expect(last_response.status).to eq(404)
    end

  end

  context 'without auth' do
    it 'returns 401 on post' do
      post '/sendgrid', '{}'
      expect(last_response.status).to eq(401)
    end
  end

  context 'with bad auth' do
    before do
      basic_authorize(username, 'meow')
    end

    it 'returns 401 on post' do
      post '/sendgrid', '{}'
      expect(last_response.status).to eq(401)
    end
  end

end
