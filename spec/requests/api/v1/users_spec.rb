require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:username) { 'username' }
  let(:password) { 'Password1!@' }

  describe 'POST /api/v1/users' do
    let(:params) do
      { user: { username:, password: } }
    end

    it 'creates a new user' do
      post('/api/v1/users', params:)

      expect(response).to have_http_status(:created)
      expect(response_body).to include('username' => 'username')
    end
  end
end
