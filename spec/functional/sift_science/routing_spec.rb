require 'rspec'

RSpec.describe 'sift science routing', type: :functional do
  let(:app) { Webhook::Web }
  let(:body) { '{"id":"e2260152130a5844d9b38e2261eaea827ffffeaaca739bff:ban_user_1","action":{"id":"ban_user_1","href":"https://api3.siftscience.com/v3/accounts/52dee51afe6b7ce6b0000047/actions/ban_user_1"},"entity":{"id":"19884820","href":"https://api3.siftscience.com/v3/accounts/52dee51afe6b7ce6b0000047/users/19884820"},"time":1465482241024,"triggers":[{"type":"formula","trigger":{"id":"575076cee4b094a673cf3a3c","href":"https://api3.siftscience.com/v3/accounts/52dee51afe6b7ce6b0000047/formulas/575076cee4b094a673cf3a3c"}}]}' }
  let(:headers) { {'HTTP_X_SIFT_SCIENCE_SIGNATURE' => 'sha1=f6ad932ba8057d11fe1b6c3e8e4cf8b1b6770139'} }
  let(:secret) { 'abcdefghijkl1234' }

  context 'with secret enabled' do

    before do
      expect(ENV).to receive(:[]).with('SIFT_SCIENCE_VALIDATION_DISABLED') { nil }
      expect(ENV).to receive(:[]).with('SIFT_SCIENCE_APP_SECRET').at_least(:once) { secret }
    end

    context 'authorization' do
      context 'with a valid sha1 hmac' do
        it 'returns http 200' do
          post '/sift_science', body, headers
          expect(last_response.status).to eq(200)
        end
      end

      context 'with and invalid sha1 hmac' do
        let(:invalid_headers) { {'HTTP_X_SIFT_SCIENCE_SIGNATURE' => 'sha1=1234566789012345678901234567890123456780'} }
        it 'returns http 401' do
          post '/sift_science', body, invalid_headers
          expect(last_response.status).to eq(401)
        end
      end

      context 'with no sha1 hmac' do
        it 'returns http 401' do
          post '/sift_science', body, {}
          expect(last_response.status).to eq(401)
        end
      end
    end
  end

  context 'with secret disabled' do

    before do
      expect(ENV).to receive(:[]).with ('SIFT_SCIENCE_VALIDATION_DISABLED') { 'hoooo' }
      expect(ENV).to_not receive(:[]).with ('SIFT_SCIENCE_APP_SECRET')
    end

    context 'authorization' do
      context 'with a valid sha1 hmac' do
        it 'returns http 200' do
          post '/sift_science', body, headers
          expect(last_response.status).to eq(200)
        end
      end

      context 'with and invalid sha1 hmac' do
        let(:invalid_headers) { {'HTTP_X_SIFT_SCIENCE_SIGNATURE' => 'sha1=1234566789012345678901234567890123456780'} }
        it 'returns http 401' do
          post '/sift_science', body, invalid_headers
          expect(last_response.status).to eq(200)
        end
      end

      context 'with no sha1 hmac' do
        it 'returns http 401' do
          post '/sift_science', body, {}
          expect(last_response.status).to eq(200)
        end
      end
    end
  end


end
