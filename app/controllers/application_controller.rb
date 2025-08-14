# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :set_current_user
  
  # Health check endpoint for load balancers
  def health
    render json: {
      status: 'healthy',
      timestamp: Time.current.iso8601,
      version: '1.0.0'
    }, status: :ok
  end

  protected

  # Extract current user from JWT payload set by RackJwtAegis middleware
  def set_current_user
    if request.env['rack_jwt_aegis.payload']
      payload = request.env['rack_jwt_aegis.payload']
      @current_user_id = payload['user_id'] || payload['sub']
      @current_tenant_id = payload['tenant_id'] || payload['company_group_id']
      @current_company_slug = params[:company_slug]
    end
  end

  def current_user
    return nil unless @current_user_id
    
    @current_user ||= User.find_by(id: @current_user_id)
  end

  def current_tenant_id
    @current_tenant_id
  end

  def current_company_slug
    @current_company_slug
  end

  # Authorization helpers
  def ensure_user_authenticated
    unless current_user
      render json: { 
        error: 'Authentication required',
        message: 'You must be authenticated to access this resource'
      }, status: :unauthorized
    end
  end

  def ensure_company_access
    return unless current_user && current_company_slug
    
    unless current_user.has_company_access?(current_company_slug)
      render json: { 
        error: 'Forbidden',
        message: 'You do not have access to this company'
      }, status: :forbidden
    end
  end

  def ensure_module_access(module_name, action = :read)
    unless RbacPermissionsService.can_access_module?(
      current_user.id, 
      module_name, 
      action, 
      current_company_slug
    )
      render json: { 
        error: 'Forbidden',
        message: "You do not have #{action} access to the #{module_name} module"
      }, status: :forbidden
    end
  end

  # Error handling
  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ArgumentError, with: :handle_bad_request

  private

  def handle_standard_error(exception)
    Rails.logger.error "ApplicationController Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render json: {
      error: 'Internal Server Error',
      message: 'An unexpected error occurred'
    }, status: :internal_server_error
  end

  def handle_not_found(exception)
    render json: {
      error: 'Not Found',
      message: exception.message
    }, status: :not_found
  end

  def handle_bad_request(exception)
    render json: {
      error: 'Bad Request',
      message: exception.message
    }, status: :bad_request
  end
end
