module Api
  module V1
    class AuthenticationController < ApplicationController
      before_action :set_user, only: :create

      def create
        unless @user&.authenticate(params.require(:password))
          raise AuthenticationError, "Invalid username or password"
        end

        render json: { token: token }, status: :created
      end

      private

      def token
        AuthenticationTokenService.encode(@user.id)
      end

      def set_user
        @user ||= User.find_by("username = ?", params.require(:username))
      end
    end
  end
end
