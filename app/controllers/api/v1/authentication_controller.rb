# frozen_string_literal: true

class Api::V1::AuthenticationController < ApplicationController
  before_action :set_company_group, only: [ :login ]

  def login
    user = @company_group.users.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JwtService.generate_token_for_user(user)
      render json: {
        token: token,
        user: user_response_data(user),
      }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  def refresh
    token = extract_token_from_header
    return render json: { error: 'Token not provided' }, status: :unauthorized unless token

    begin
      decoded_token = JwtService.decode(token)
      user = User.find(decoded_token[:user_id])
      new_token = JwtService.generate_token_for_user(user)

      render json: {
        token: new_token,
        user: user_response_data(user),
      }, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :unauthorized
    end
  end

  private

  def set_company_group
    subdomain = request.subdomain
    @company_group = CompanyGroup.find_by(domain_name: subdomain)

    unless @company_group
      render json: { error: 'Invalid company group' }, status: :not_found
    end
  end

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header&.start_with?('Bearer ')

    auth_header.split(' ').last
  end

  def user_response_data(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      company_group: {
        id: user.company_group.id,
        name: user.company_group.name,
        domain_name: user.company_group.domain_name,
      },
      companies: user.companies.map { |c| { id: c.id, name: c.name, slug: c.slug } },
      company_group_roles: user.company_group_roles.map { |r| { id: r.id, name: r.name } },
      company_roles: user.company_users.joins(:company_roles).includes(:company_roles, :company)
                         .map { |cu| cu.company_roles.map { |cr| { id: cr.id, name: cr.name, company_slug: cu.company.slug } } }
                         .flatten,
    }
  end
end
