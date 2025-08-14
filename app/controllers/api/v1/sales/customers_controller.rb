# frozen_string_literal: true

class Api::V1::Sales::CustomersController < ApplicationController
  def index
    render json: {
      message: 'Customers retrieved successfully',
      data: [],
      permissions: current_user_permissions('sales', 'customers')
    }, status: :ok
  end

  def show
    render json: {
      message: 'Customer retrieved successfully',
      data: { id: params[:id] },
      permissions: current_user_permissions('sales', 'customers')
    }, status: :ok
  end

  def create
    render json: {
      message: 'Customer created successfully',
      data: { id: rand(1000..9999) }
    }, status: :created
  end

  def update
    render json: {
      message: 'Customer updated successfully',
      data: { id: params[:id] }
    }, status: :ok
  end

  def destroy
    render json: {
      message: 'Customer deleted successfully'
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