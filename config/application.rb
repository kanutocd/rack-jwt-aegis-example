# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Liba
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Configure RackJwtAegis middleware for JWT authentication with multi-tenant support
    config.middleware.insert_before 0, RackJwtAegis::Middleware, {
      jwt_secret: ENV['JWT_SECRET'] || 'your-super-secret-jwt-key-for-development-only-change-in-production',
      tenant_id_header_name: 'X-Company-Group-Id',
      validate_tenant_id: true,
      validate_pathname_slug: true,
      validate_subdomain: true,
      skip_paths: [ '/api/v1/auth/login', '/up', '/api/v1/health' ],
      # Custom JWT payload mapping for multi-tenant access control
      payload_mapping: {
        user_id: :sub,
        tenant_id: :company_group_id,
        subdomain: :company_group_domain,
        pathname_slugs: :company_slugs,
        role_ids: :role_ids,
      },
    }
  end
end
