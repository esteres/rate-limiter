class AuthenticationTokenService
  EXPIRATION_TIME_IN_MINUTES = 20
  ALGORITHM_TYPE = "HS256".freeze
  SECRET_KEY = Rails.application.credentials.secret_key_base

  class << self
    def encode(user_id)
      JWT.encode(
        {
          user_id: user_id,
          exp: expiration_timestamp
        },
        SECRET_KEY,
        ALGORITHM_TYPE
      )
    end

    def decode(token)
      decoded_token = JWT.decode(
        token,
        SECRET_KEY,
        true,
        { algorithm: ALGORITHM_TYPE }
      ).first

      decoded_token["user_id"]
    end

    private

    def expiration_time_in_seconds
      EXPIRATION_TIME_IN_MINUTES * 60
    end

    def expiration_timestamp
     Time.now.to_i + expiration_time_in_seconds
    end
  end
end
