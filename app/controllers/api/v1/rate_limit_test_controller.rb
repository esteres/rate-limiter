module Api
  module V1
    class RateLimitTestController < ApplicationController
      before_action :authenticate_user!
      before_action :enforce_rate_limit

      def test
        render json: { status: "allowed" }
      end
    end
  end
end
