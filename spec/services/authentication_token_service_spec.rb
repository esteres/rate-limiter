require 'rails_helper'

RSpec.describe AuthenticationTokenService, type: :service do
  let(:user_id) { 1 }
  let(:token) { described_class.encode(user_id) }

  describe '.encode' do
    it 'encodes the user_id into a JWT token' do
      expect(token).to be_a(String)
    end
  end

  describe '.decode' do
    it 'decodes the JWT token and returns the user_id' do
      decoded_user_id = described_class.decode(token)
      expect(decoded_user_id).to eq(user_id)
    end
  end
end
