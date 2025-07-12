require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /authenticate' do
    let(:user) { create(:user) }
    let(:token) { 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxfQ.SHRALNlfZeIZv30Zxkhmf74jOwgo8XAkD5MPky6eT0Y' }

    before do
      allow(AuthenticationTokenService).to receive(:encode).and_return(token)
    end

    it 'authenticates the client' do
      post '/api/v1/authenticate', params: {
        username: user.username,
        password: user.password
      }

      expect(response).to have_http_status(:created)
      expect(response_body).to eq({
        'token' => token
      })
    end

    it 'returns error when password is incorrect' do
      post '/api/v1/authenticate', params: {
        username: user.username,
        password: 'incorrect'
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
