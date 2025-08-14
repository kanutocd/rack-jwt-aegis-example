# frozen_string_literal: true

class JwtService
  SECRET_KEY = ENV['JWT_SECRET'] || 'your-super-secret-jwt-key-for-development-only-change-in-production'

  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY, 'HS256')
    end

    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
      HashWithIndifferentAccess.new decoded
    rescue JWT::DecodeError => e
      raise StandardError, "Invalid token: #{e.message}"
    end

    def generate_token_for_user(user)
      payload = build_user_payload(user)
      encode(payload)
    end

    private

    def build_user_payload(user)
      {
        sub: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        company_group_id: user.company_group.id,
        company_group_domain: user.company_group.domain_name,
        company_slugs: user.companies.pluck(:slug),
        # company_group_role_ids: user.company_group_roles.pluck(:id),
        # company_role_ids: user.company_users.joins(:company_roles).pluck('company_roles.id').uniq,
        iat: Time.current.to_i,
      }
    end
  end
end
