class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token

  class AuthenticationError < StandardError
    def initialize(message = "Invalid token. Please log in again.")
      super(message)
    end
  end

  rescue_from AuthenticationError, with: :handle_unauthenticated
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def authenticate_user!
    token, _options = token_and_options(request)
    user_id = AuthenticationTokenService.decode(token)
    user = User.find_by("id = ?", user_id)

    raise AuthenticationError, "User not found for token" if user.nil?

    @current_user_id = user_id
  rescue JWT::ExpiredSignature
    raise AuthenticationError, "Your token has expired. Please log in again."
  rescue JWT::DecodeError
    raise AuthenticationError
  end

  def handle_unauthenticated(error)
    render json: {
      error: error.message
    }, status: :unauthorized
  end

  def not_found(error)
    render json: { error: "User not found" }, status: :not_found
  end
end
