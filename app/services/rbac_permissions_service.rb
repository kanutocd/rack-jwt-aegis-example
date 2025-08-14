# frozen_string_literal: true

class RbacPermissionsService
  CACHE_EXPIRY = 1.hour
  PERMISSION_CACHE_PREFIX = 'rbac_permissions'

  class << self
    def permissions_for_user(user_id, company_group_id = nil)
      cache_key = build_cache_key(user_id, company_group_id)
      
      Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
        generate_permissions_for_user(user_id, company_group_id)
      end
    end

    def invalidate_user_permissions(user_id, company_group_id = nil)
      cache_key = build_cache_key(user_id, company_group_id)
      Rails.cache.delete(cache_key)
    end

    def module_permissions_for_user(user_id, module_name, company_slug = nil)
      permissions = permissions_for_user(user_id)
      module_perms = permissions.dig(:modules, module_name.to_sym) || {}
      
      if company_slug
        company_perms = module_perms.dig(:companies, company_slug.to_sym) || {}
        module_perms.merge(company_perms)
      else
        module_perms.except(:companies)
      end
    end

    def can_access_module?(user_id, module_name, action = :read, company_slug = nil)
      perms = module_permissions_for_user(user_id, module_name, company_slug)
      
      case action.to_sym
      when :read
        perms[:can_read] || perms[:can_write] || perms[:can_admin]
      when :write
        perms[:can_write] || perms[:can_admin]
      when :admin
        perms[:can_admin]
      else
        false
      end
    end

    private

    def build_cache_key(user_id, company_group_id)
      "#{PERMISSION_CACHE_PREFIX}:user_#{user_id}:group_#{company_group_id}"
    end

    def generate_permissions_for_user(user_id, company_group_id)
      user = User.includes(:companies, :company_group_roles, company_users: :company_roles)
                 .find(user_id)
      
      return {} unless user&.company_group_id == company_group_id.to_i

      {
        user_id: user.id,
        company_group_id: user.company_group_id,
        role: user.primary_role,
        global_permissions: generate_global_permissions(user),
        modules: generate_module_permissions(user),
        companies: generate_company_permissions(user),
        generated_at: Time.current.iso8601
      }
    end

    def generate_global_permissions(user)
      permissions = {
        can_read_all: user.owner? || user.admin?,
        can_write_all: user.owner?,
        can_manage_users: user.owner? || user.admin?,
        can_manage_companies: user.owner?,
        can_view_analytics: user.owner? || user.admin? || user.cfo?
      }
      
      permissions
    end

    def generate_module_permissions(user)
      modules = {}
      
      # Accounting Module
      modules[:accounting] = {
        can_read: user.can_access_accounting?,
        can_write: user.owner? || user.admin? || user.cfo?,
        can_admin: user.owner? || user.admin?,
        submodules: {
          reports: { can_read: user.can_access_accounting?, can_write: user.cfo? || user.owner? || user.admin? },
          account_receivables: { can_read: user.can_access_accounting?, can_write: user.cfo? || user.owner? || user.admin? },
          account_payables: { can_read: user.can_access_accounting?, can_write: user.cfo? || user.owner? || user.admin? }
        }
      }

      # Inventory Module
      modules[:inventory] = {
        can_read: user.can_access_inventory?,
        can_write: user.has_role?('Inventory Manager') || user.owner? || user.admin?,
        can_admin: user.owner? || user.admin?,
        submodules: {
          products: { can_read: user.can_access_inventory?, can_write: user.has_role?('Inventory Manager') || user.owner? || user.admin? },
          categories: { can_read: user.can_access_inventory?, can_write: user.has_role?('Inventory Manager') || user.owner? || user.admin? }
        }
      }

      # Procurement Module
      modules[:procurement] = {
        can_read: user.can_access_procurement?,
        can_write: user.has_role?('Procurement Manager') || user.owner? || user.admin?,
        can_admin: user.owner? || user.admin?,
        submodules: {
          analytics: { can_read: user.can_access_procurement?, can_write: user.has_role?('Procurement Manager') || user.owner? || user.admin? },
          suppliers: { can_read: user.can_access_procurement?, can_write: user.has_role?('Procurement Manager') || user.owner? || user.admin? }
        }
      }

      # Sales Module
      modules[:sales] = {
        can_read: user.can_access_sales?,
        can_write: user.has_role?('Sales Manager') || user.has_role?('Sales Representative') || user.owner? || user.admin?,
        can_admin: user.owner? || user.admin?,
        submodules: {
          leads: { can_read: user.can_access_sales?, can_write: user.has_role?('Sales Manager') || user.has_role?('Sales Representative') || user.owner? || user.admin? },
          opportunities: { can_read: user.can_access_sales?, can_write: user.has_role?('Sales Manager') || user.has_role?('Sales Representative') || user.owner? || user.admin? },
          customers: { can_read: user.can_access_sales?, can_write: user.has_role?('Sales Manager') || user.owner? || user.admin? }
        }
      }

      # Retail Module
      modules[:retail] = {
        can_read: user.can_access_retail?,
        can_write: user.has_role?('Retail Manager') || user.owner? || user.admin?,
        can_admin: user.owner? || user.admin?,
        submodules: {
          pos: { can_read: user.can_access_retail?, can_write: user.has_role?('Retail Manager') || user.owner? || user.admin? },
          stores: { can_read: user.can_access_retail?, can_write: user.has_role?('Retail Manager') || user.owner? || user.admin? }
        }
      }

      # Warehouse Module
      modules[:warehouse] = {
        can_read: user.can_access_warehouse?,
        can_write: user.has_role?('Warehouse Manager') || user.owner? || user.admin?,
        can_admin: user.owner? || user.admin?,
        submodules: {
          locations: { can_read: user.can_access_warehouse?, can_write: user.has_role?('Warehouse Manager') || user.owner? || user.admin? },
          shipments: { can_read: user.can_access_warehouse?, can_write: user.has_role?('Warehouse Manager') || user.owner? || user.admin? }
        }
      }

      # Wholesale Module
      modules[:wholesale] = {
        can_read: user.can_access_wholesale?,
        can_write: user.has_role?('Wholesale Manager') || user.owner? || user.admin?,
        can_admin: user.owner? || user.admin?,
        submodules: {
          bulk_orders: { can_read: user.can_access_wholesale?, can_write: user.has_role?('Wholesale Manager') || user.owner? || user.admin? },
          distributors: { can_read: user.can_access_wholesale?, can_write: user.has_role?('Wholesale Manager') || user.owner? || user.admin? }
        }
      }

      modules
    end

    def generate_company_permissions(user)
      permissions = {}
      
      user.companies.each do |company|
        company_roles = user.company_users.find_by(company: company)&.company_roles || []
        
        permissions[company.slug.to_sym] = {
          company_id: company.id,
          company_name: company.name,
          roles: company_roles.pluck(:name),
          can_read: true, # All assigned users can read company data
          can_write: company_roles.any? { |role| %w[Manager Admin].include?(role.name) },
          can_admin: company_roles.any? { |role| role.name == 'Admin' }
        }
      end

      permissions
    end
  end
end