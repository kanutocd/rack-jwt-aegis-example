# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :company_group
  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users
  has_many :company_roles, through: :company_users
  has_and_belongs_to_many :company_group_roles

  has_secure_password

  validates :email, presence: true, uniqueness: { scope: :company_group_id }
  validates :first_name, presence: true
  validates :last_name, presence: true

  after_create :assign_owner_role_if_first_user

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def jwt_payload_data
    {
      sub: id,  # Standard JWT subject claim
      email: email,
      first_name: first_name,
      last_name: last_name,
      company_group_id: company_group.id,
      company_group_domain_name: company_group.domain_name,
      company_slugs: companies.pluck(:slug),
      iat: Time.current.to_i,  # Issued at
      exp: 24.hours.from_now.to_i,  # Expires at
    }
  end

  def generate_jwt_token
    JwtService.generate_token_for_user(self)
  end

  def has_role?(role_name)
    company_group_roles.exists?(name: role_name.to_s)
  end

  def has_company_access?(company_slug)
    companies.exists?(slug: company_slug.to_s)
  end

  def owner?
    has_role?('Owner')
  end

  def admin?
    has_role?('Admin')
  end

  def cfo?
    has_role?('CFO')
  end

  def primary_role
    return 'super_admin' if owner?
    return 'company_group_admin' if admin?
    return 'company_admin' if cfo?
    'employee'
  end

  def accessible_erp_modules
    modules = []
    modules << 'accounting' if can_access_accounting?
    modules << 'inventory' if can_access_inventory?
    modules << 'procurement' if can_access_procurement?
    modules << 'sales' if can_access_sales?
    modules << 'retail' if can_access_retail?
    modules << 'warehouse' if can_access_warehouse?
    modules << 'wholesale' if can_access_wholesale?
    modules
  end

  def can_access_accounting?
    cfo? || admin? || owner? || has_role?('Accountant')
  end

  def can_access_inventory?
    admin? || owner? || has_role?('Inventory Manager') || has_role?('Warehouse Manager')
  end

  def can_access_procurement?
    admin? || owner? || has_role?('Procurement Manager')
  end

  def can_access_sales?
    admin? || owner? || has_role?('Sales Manager') || has_role?('Sales Representative')
  end

  def can_access_retail?
    admin? || owner? || has_role?('Retail Manager')
  end

  def can_access_warehouse?
    admin? || owner? || has_role?('Warehouse Manager')
  end

  def can_access_wholesale?
    admin? || owner? || has_role?('Wholesale Manager')
  end

  def has_inventory_access?
    can_access_inventory?
  end

  def has_procurement_access?
    can_access_procurement?
  end

  def has_sales_access?
    can_access_sales?
  end

  def has_retail_access?
    can_access_retail?
  end

  def has_warehouse_access?
    can_access_warehouse?
  end

  def has_wholesale_access?
    can_access_wholesale?
  end

  private

  def assign_owner_role_if_first_user
    company_group.assign_owner_role_to_first_user!
  end
end
