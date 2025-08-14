# frozen_string_literal: true

module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user, :current_company_group
  end

  private

  def authenticate_request
    token = extract_token_from_header
    return render_unauthorized('Token not provided') unless token

    begin
      decoded_token = JwtService.decode(token)
      @current_user = User.find(decoded_token[:user_id])
      @current_company_group = @current_user.company_group

      # Verify subdomain matches token's company group
      unless request.subdomain == decoded_token[:company_group_domain]
        render_unauthorized('Invalid company group for token')
      end

    rescue ActiveRecord::RecordNotFound
      render_unauthorized('User not found')
    rescue StandardError => e
      render_unauthorized(e.message)
    end
  end

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header&.start_with?('Bearer ')

    auth_header.split(' ').last
  end

  def render_unauthorized(message = 'Unauthorized')
    render json: { error: message }, status: :unauthorized
  end

  def current_user_companies
    @current_user_companies ||= current_user.companies
  end

  def current_user_company_slugs
    @current_user_company_slugs ||= current_user_companies.pluck(:slug)
  end

  def current_user_roles
    @current_user_roles ||= current_user.company_group_roles.pluck(:name)
  end

  def user_has_role?(role_name)
    current_user_roles.include?(role_name.to_s)
  end

  def user_has_access_to_company?(company_slug)
    current_user_company_slugs.include?(company_slug.to_s)
  end

  def require_role(role_name)
    unless user_has_role?(role_name)
      render json: { error: "Access denied. Required role: #{role_name}" }, status: :forbidden
    end
  end

  def require_company_access(company_slug)
    unless user_has_access_to_company?(company_slug)
      render json: { error: "Access denied to company: #{company_slug}" }, status: :forbidden
    end
  end
end
