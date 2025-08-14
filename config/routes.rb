# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', :as => :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes (no company slug required)
      namespace :auth do
        post 'login', to: 'authentication#login'
        post 'refresh', to: 'authentication#refresh'
        post 'logout', to: 'authentication#logout'
      end

      # Health check route
      get 'health', to: 'application#health'

      # Company-scoped routes with company slug parameter
      # Pattern: /api/v1/{company_slug}/module/...
      # Example: POST https://acme-group.localhost.local/api/v1/acme-subsidiary/accounting/reports
      scope ':company_slug' do
        # Accounting Module - Financial management and reporting
        namespace :accounting do
          resources :reports, only: [:index, :show, :create, :update, :destroy]
          resources :account_receivables, only: [:index, :show, :create, :update, :destroy]
          resources :account_payables, only: [:index, :show, :create, :update, :destroy]
        end

        # Inventory Module - Product and stock management
        namespace :inventory do
          resources :products, only: [:index, :show, :create, :update, :destroy]
          resources :categories, only: [:index, :show, :create, :update, :destroy]
        end

        # Procurement Module - Supplier and purchasing management
        namespace :procurement do
          resources :analytics, only: [:index, :show, :create, :update, :destroy]
          resources :suppliers, only: [:index, :show, :create, :update, :destroy]
        end

        # Sales Module - Customer relationship and sales management
        namespace :sales do
          resources :leads, only: [:index, :show, :create, :update, :destroy]
          resources :opportunities, only: [:index, :show, :create, :update, :destroy]
          resources :customers, only: [:index, :show, :create, :update, :destroy]
        end

        # Retail Module - Point of sale and store management
        namespace :retail do
          resources :pos, only: [:index, :show, :create, :update, :destroy]
          resources :stores, only: [:index, :show, :create, :update, :destroy]
        end

        # Warehouse Module - Storage and logistics management
        namespace :warehouse do
          resources :locations, only: [:index, :show, :create, :update, :destroy]
          resources :shipments, only: [:index, :show, :create, :update, :destroy]
        end

        # Wholesale Module - Bulk sales and distribution
        namespace :wholesale do
          resources :bulk_orders, only: [:index, :show, :create, :update, :destroy]
          resources :distributors, only: [:index, :show, :create, :update, :destroy]
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
