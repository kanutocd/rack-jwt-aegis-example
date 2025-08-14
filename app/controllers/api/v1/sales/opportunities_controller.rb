# frozen_string_literal: true

class Api::V1::Sales::OpportunitiesController < ApplicationController
  def index
    render json: {
      message: 'Opportunities retrieved successfully',
      data: [],
      permissions: current_user_permissions('sales', 'opportunities')
    }, status: :ok
  end

  def show
    render json: {
      message: 'Opportunity retrieved successfully',
      data: { id: params[:id] },
      permissions: current_user_permissions('sales', 'opportunities')
    }, status: :ok
  end

  def create
    render json: {
      message: 'Opportunity created successfully',
      data: { id: rand(1000..9999) }
    }, status: :created
  end

  def update
    render json: {
      message: 'Opportunity updated successfully',
      data: { id: params[:id] }
    }, status: :ok
  end

  def destroy
    render json: {
      message: 'Opportunity deleted successfully'
    }, status: :ok
  end

  private

  def current_user_permissions(module_name, submodule = nil)
    return {} unless current_user
    
    RbacPermissionsService.module_permissions_for_user(
      current_user.id, 
      module_name, 
      params[:company_slug]
    )
  end
end