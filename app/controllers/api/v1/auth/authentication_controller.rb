# frozen_string_literal: true

class Api::V1::Auth::AuthenticationController < ApplicationController
  skip_before_action :set_current_user, only: [:login]

  def login
    user = authenticate_user(login_params[:email], login_params[:password])
    
    if user
      token = user.generate_jwt_token
      render json: {
        message: 'Login successful',
        token: token,
        user: user_profile(user),
        expires_at: 24.hours.from_now.iso8601
      }, status: :ok
    else
      render json: {
        error: 'Authentication failed',
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  def refresh
    if current_user
      token = current_user.generate_jwt_token
      render json: {
        message: 'Token refreshed successfully',
        token: token,
        user: user_profile(current_user),
        expires_at: 24.hours.from_now.iso8601
      }, status: :ok
    else
      render json: {
        error: 'Authentication failed',
        message: 'Invalid or expired token'
      }, status: :unauthorized
    end
  end

  def logout
    render json: {
      message: 'Logout successful'
    }, status: :ok
  end

  private

  def authenticate_user(email, password)
    return nil unless email.present? && password.present?
    
    user = User.find_by(email: email.downcase.strip)
    return nil unless user&.authenticate(password)
    
    user
  end

  def user_profile(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      role: user.primary_role,
      company_group: {
        id: user.company_group.id,
        name: user.company_group.name,
        domain_name: user.company_group.domain_name
      },
      accessible_companies: user.companies.pluck(:slug),
      accessible_modules: user.accessible_erp_modules,
      permissions: RbacPermissionsService.permissions_for_user(user.id, user.company_group_id)
    }
  end

  def login_params
    params.require(:auth).permit(:email, :password)
  end
end