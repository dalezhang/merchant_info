# frozen_string_literal: true

module Biz
  module Jwt
    extend self
    # h5 接口加签
    def hsh_encode(payload, ttl_in_minutes = 60 * 24 * 30)
      secrets_base = '$secretshello'
      payload[:exp] = ttl_in_minutes.minutes.from_now.to_i
      JWT.encode(payload, secrets_base)
    end

    # h5 接口解签
    def hsh_decode(token, leeway = nil)
      secrets_base = '$secretshello'
      begin
        decoded = JWT.decode(token, secrets_base, leeway: leeway)
        HashWithIndifferentAccess.new(decoded[0])
      rescue JWT::ExpiredSignature
        decoded = 'JWT::ExpiredSignature'
        # Handle expired token, e.g. logout user or deny access
      rescue JWT::InvalidJtiError
        decoded = 'JWT::InvalidJtiError'
      rescue JWT::VerificationError
        decoded = 'JWT::VerificationError'
      end
    end

    # h5 接口验证
    def h5_verify?(token)
      result = hsh_decode token
      result.class.to_s != 'Hash' ? [true, result] : [false, result]
    end
  end
end
