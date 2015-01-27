require 'spec_helper'

RSpec.describe 'status check routing', type: :functional do
  let(:app) { Webhook::Web }

  let(:body) { {"id" => "1"} }
  let(:secret) { 'secret' }
  let(:body_hmac) { Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret, Oj.dump(body))).strip }

  before do
    allow_any_instance_of(Webhook::Shopify).to receive(:app_secret) { secret }
  end

  def rack_env(hmac)
    {
      'HTTP_X_SHOPIFY_HMAC_SHA256' => hmac,
      'Content-Type' => 'application/json',
    }
  end

  context 'with HTTP_X_SHOPIFY_HMAC_SHA256 header' do
    context 'when submitted hmac and calculated hmac are the same' do
      it 'continues' do
        get '/shopify/order/fulfilled', body, rack_env(body_hmac)
        expect(last_response.status).to eq(200)
      end
    end
    context 'when submitted hmac and calculated hmac differ' do
      it 'returns 401 with empty body' do
        get '/shopify/order/fulfilled', body, rack_env('bad')
        expect(last_response.status).to eq(401)
      end
    end
  end

  context 'without HTTP_X_SHOPIFY_HMAC_SHA256 header' do
    it 'returns a 401' do
      get '/shopify/order/fulfilled', body
      expect(last_response.status).to eq(401)
    end
  end
end