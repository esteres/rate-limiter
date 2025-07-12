require 'rails_helper'

RSpec.describe "Rate Limiting", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:headers) do
    token = AuthenticationTokenService.encode(user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  let(:endpoint) { "/api/v1/rate_limit_test" }

  before do
    $redis.del("rate_limit:user:#{user.id}")
  end

  it "allows up to 3 requests within 30 seconds" do
    3.times do |i|
      get endpoint, headers: headers
      expect(response).to have_http_status(:ok), "Failed on request #{i + 1}"
      expect(response_body["status"]).to eq("allowed")
    end
  end

  it "allows a new request once an old one slides out of the window" do
    freeze_time do
      # First 3 requests
      get endpoint, headers: headers # t = 0s
      expect(response).to have_http_status(:ok)

      travel 10.seconds
      get endpoint, headers: headers # t = 10s
      expect(response).to have_http_status(:ok)

      travel 10.seconds
      get endpoint, headers: headers # t = 20s
      expect(response).to have_http_status(:ok)

      # Should be blocked 3 requests still within the 30s window
      travel 5.seconds # t = 25s
      get endpoint, headers: headers
      expect(response).to have_http_status(:too_many_requests)

      # Advance past first request’s expiry (t = 31s)
      travel 6.seconds
      get endpoint, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response_body["status"]).to eq("allowed")
    end
  end
end
