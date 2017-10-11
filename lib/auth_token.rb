class AuthToken
  DEFAULT_TTL = 43200 # 30 days in seconds

  # Encode a hash in a json web token
  #
  # @see JWT#encode
  #
  # @param [Hash] payload the payload to encode
  # @param [Fixnum] ttl in minutes
  def self.encode(payload, ttl_in_minutes = DEFAULT_TTL)
    payload[:exp] = ttl_in_minutes.minutes.from_now.to_i
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  # Decode a token and return the payload inside
  #
  # @see JWT#decode
  # @see JWT::Verify#verify_expiration
  # @see JWT::Verify#verify_not_before
  #
  # @raise [JWT::DecodeError] Nil JSON web token, No verification key available, Not enough or too many segments
  # @raise [JWT::ExpiredSignature] Signature has expired
  # @raise [JWT::ImmatureSignature] Signature nbf has not been reached
  #
  # By default, JWT.decode without any options will verify:
  #   ref:               https://github.com/jwt/ruby-jwt/blob/master/lib/jwt/verify.rb
  #   verify_expiration: can raise JWT::ExpiredSignature
  #   verify_not_before: can raise JWT::ImmatureSignature
  def self.decode(token, leeway = nil)
    decoded = JWT.decode(token, Rails.application.secrets.secret_key_base, leeway: leeway)
    HashWithIndifferentAccess.new(decoded[0])
  end
end
