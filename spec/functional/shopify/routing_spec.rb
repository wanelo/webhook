require 'spec_helper'

RSpec.describe 'status check routing', type: :functional do
  let(:app) { Webhook::Web }

  let(:body) { Oj.dump({"id" => "1"}) }
  let(:secret) { 'secret' }

  def rack_env(hmac)
    {
      'HTTP_X_SHOPIFY_HMAC_SHA256' => hmac,
      'Content-Type' => 'application/json',
    }
  end

  shared_examples 'hmac aware' do
    context 'with store id in path' do
      it 'includes  store id in payload' do
        post '/shopify/1/orders/fulfilled', body, rack_env(body_hmac)
        expect(last_response.status).to eq(200)
      end
    end

    context 'with HTTP_X_SHOPIFY_HMAC_SHA256 header' do
      context 'when submitted hmac and calculated hmac are the same' do
        it 'continues' do
          post '/shopify/orders/fulfilled', body, rack_env(body_hmac)
          expect(last_response.status).to eq(200)
        end
      end
      context 'when submitted hmac and calculated hmac differ' do
        it 'returns 401 with empty body' do
          post '/shopify/orders/fulfilled', body, rack_env('bad')
          expect(last_response.status).to eq(401)
        end
      end
    end
  end

  it_behaves_like 'hmac aware' do
    before do
      allow(ENV).to receive(:[])
      expect(ENV).to receive(:[]).with ('SHOPIFY_APP_SECRET') { secret }
      expect(ENV).to receive(:[]).with ('SHOPIFY_CHANNEL_DEV_APP_SECRET') { 'dvds' }
      expect(ENV).to receive(:[]).with ('SHOPIFY_CHANNEL_APP_SECRET') { 'dfhdffd' }
    end
    let(:body_hmac) { Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret, body).strip) }
  end

  it_behaves_like 'hmac aware' do
    before do
      allow(ENV).to receive(:[])
      expect(ENV).to receive(:[]).with ('SHOPIFY_APP_SECRET') { 'sdfdsfd' }
      expect(ENV).to receive(:[]).with ('SHOPIFY_CHANNEL_DEV_APP_SECRET') { 'fffgg' }
      expect(ENV).to receive(:[]).with ('SHOPIFY_CHANNEL_APP_SECRET') { secret }
    end
    let(:body_hmac) { Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret, body).strip) }
  end

  it_behaves_like 'hmac aware' do
    before do
      allow(ENV).to receive(:[])
      expect(ENV).to receive(:[]).with ('SHOPIFY_APP_SECRET') { 'sdfdsfd' }
      expect(ENV).to receive(:[]).with ('SHOPIFY_CHANNEL_DEV_APP_SECRET') { secret }
      expect(ENV).to receive(:[]).with ('SHOPIFY_CHANNEL_APP_SECRET') { 'dfhdffd' }
    end
    let(:body_hmac) { Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret, body).strip) }
  end


  context 'without HTTP_X_SHOPIFY_HMAC_SHA256 header' do
    it 'returns a 401' do
      post '/shopify/orders/fulfilled', body
      expect(last_response.status).to eq(401)
    end
  end
end
