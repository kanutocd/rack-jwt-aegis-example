# frozen_string_literal: true

# Database seeds for RackJwtAegis Example Application
# Demonstrates multi-tenant ERP SaaS with hierarchical Company Group → Company structure

puts "🌱 Starting database seed..."

# Clear existing data in development
if Rails.env.development?
  puts "🧹 Cleaning existing data..."
  [User, CompanyUser, Company, CompanyGroup, CompanyGroupRole, CompanyRole].each(&:destroy_all)
end

# Create Company Group - Acme Corporation (must be created first)
puts "🏭 Creating Company Group..."
acme_group = CompanyGroup.find_or_create_by!(name: 'Acme Corporation') do |group|
  group.domain_name = 'acme-corp'
end

# Get Company Group Roles (created automatically by the callback)
puts "👥 Getting Company Group Roles..."
owner_role = acme_group.company_group_roles.find_by(name: 'Owner')
admin_role = acme_group.company_group_roles.find_by(name: 'Admin')
cfo_role = acme_group.company_group_roles.find_by(name: 'CFO')

# Create additional roles if needed
accountant_role = CompanyGroupRole.find_or_create_by!(name: 'Accountant', company_group: acme_group) do |role|
  role.description = 'Group Accountant - Accounting access across companies'
end

# Create Companies under Acme Corporation
puts "🏢 Creating Companies..."
acme_manufacturing = Company.find_or_create_by!(name: 'Acme Manufacturing', company_group: acme_group) do |company|
  company.slug = 'acme-manufacturing'
end

acme_retail = Company.find_or_create_by!(name: 'Acme Retail', company_group: acme_group) do |company|
  company.slug = 'acme-retail'
end

acme_logistics = Company.find_or_create_by!(name: 'Acme Logistics', company_group: acme_group) do |company|
  company.slug = 'acme-logistics'
end

acme_tech = Company.find_or_create_by!(name: 'Acme Technology', company_group: acme_group) do |company|
  company.slug = 'acme-tech'
end

acme_wholesale = Company.find_or_create_by!(name: 'Acme Wholesale', company_group: acme_group) do |company|
  company.slug = 'acme-wholesale'
end

# Create additional Company Roles (beyond the defaults Admin/Ordinary)
puts "🏢 Creating Additional Company Roles..."
companies = [acme_manufacturing, acme_retail, acme_logistics, acme_tech, acme_wholesale]
additional_roles = [
  'Manager',
  'Inventory Manager',
  'Sales Manager',
  'Sales Representative',
  'Procurement Manager',
  'Warehouse Manager',
  'Retail Manager',
  'Wholesale Manager',
  'Employee'
]

# Create additional roles for each company
companies.each do |company|
  additional_roles.each do |role_name|
    CompanyRole.find_or_create_by!(name: role_name, company: company)
  end
end

# Helper method to find roles
def find_company_role(company, role_name)
  CompanyRole.find_by!(name: role_name, company: company)
end

# Create Users with different access levels
puts "👤 Creating Users..."

# 1. Super Admin - Access to everything
super_admin = User.find_or_create_by!(email: 'owner@acme-corp.com', company_group: acme_group) do |user|
  user.first_name = 'John'
  user.last_name = 'Acme'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end
super_admin.company_group_roles << owner_role unless super_admin.company_group_roles.include?(owner_role)

# 2. Group Admin - Administrative access across companies
group_admin = User.find_or_create_by!(email: 'admin@acme-corp.com', company_group: acme_group) do |user|
  user.first_name = 'Sarah'
  user.last_name = 'Johnson'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end
group_admin.company_group_roles << admin_role unless group_admin.company_group_roles.include?(admin_role)

# 3. Group CFO - Financial oversight
group_cfo = User.find_or_create_by!(email: 'cfo@acme-corp.com', company_group: acme_group) do |user|
  user.first_name = 'Michael'
  user.last_name = 'Thompson'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end
group_cfo.company_group_roles << cfo_role unless group_cfo.company_group_roles.include?(cfo_role)

# 4. Manufacturing Manager - Access to manufacturing and logistics
manufacturing_manager = User.find_or_create_by!(email: 'manager@acme-manufacturing.com', company_group: acme_group) do |user|
  user.first_name = 'David'
  user.last_name = 'Wilson'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

# 5. Retail Manager - Access to retail operations
retail_manager = User.find_or_create_by!(email: 'manager@acme-retail.com', company_group: acme_group) do |user|
  user.first_name = 'Emily'
  user.last_name = 'Davis'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

# 6. Sales Representative - Limited to sales functions
sales_rep = User.find_or_create_by!(email: 'sales@acme-retail.com', company_group: acme_group) do |user|
  user.first_name = 'Robert'
  user.last_name = 'Miller'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

# 7. Tech Lead - Technology company access
tech_lead = User.find_or_create_by!(email: 'lead@acme-tech.com', company_group: acme_group) do |user|
  user.first_name = 'Lisa'
  user.last_name = 'Chen'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

# 8. Warehouse Supervisor - Logistics and warehouse
warehouse_supervisor = User.find_or_create_by!(email: 'warehouse@acme-logistics.com', company_group: acme_group) do |user|
  user.first_name = 'James'
  user.last_name = 'Rodriguez'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

# 9. Procurement Specialist - Multi-company procurement
procurement_specialist = User.find_or_create_by!(email: 'procurement@acme-corp.com', company_group: acme_group) do |user|
  user.first_name = 'Amanda'
  user.last_name = 'Garcia'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

# 10. Wholesale Director - Wholesale operations
wholesale_director = User.find_or_create_by!(email: 'director@acme-wholesale.com', company_group: acme_group) do |user|
  user.first_name = 'Kevin'
  user.last_name = 'Brown'
  user.password = 'password123'
  user.password_confirmation = 'password123'
end

puts "🔗 Assigning Users to Companies with Roles..."

# Assign company roles and memberships
company_assignments = [
  # Super Admin - Access to all companies as Admin
  [super_admin, acme_manufacturing, ['Admin']],
  [super_admin, acme_retail, ['Admin']],
  [super_admin, acme_logistics, ['Admin']],
  [super_admin, acme_tech, ['Admin']],
  [super_admin, acme_wholesale, ['Admin']],

  # Group Admin - Admin access to key companies
  [group_admin, acme_manufacturing, ['Admin']],
  [group_admin, acme_retail, ['Admin']],
  [group_admin, acme_logistics, ['Manager']],

  # Group CFO - Financial oversight across all companies
  [group_cfo, acme_manufacturing, ['Manager']],
  [group_cfo, acme_retail, ['Manager']],
  [group_cfo, acme_logistics, ['Manager']],
  [group_cfo, acme_tech, ['Manager']],
  [group_cfo, acme_wholesale, ['Manager']],

  # Manufacturing Manager - Manufacturing and logistics focus
  [manufacturing_manager, acme_manufacturing, ['Admin', 'Inventory Manager']],
  [manufacturing_manager, acme_logistics, ['Warehouse Manager']],

  # Retail Manager - Retail operations
  [retail_manager, acme_retail, ['Retail Manager', 'Sales Manager']],

  # Sales Representative - Retail sales only
  [sales_rep, acme_retail, ['Sales Representative']],

  # Tech Lead - Technology company admin
  [tech_lead, acme_tech, ['Admin', 'Manager']],

  # Warehouse Supervisor - Logistics focus
  [warehouse_supervisor, acme_logistics, ['Warehouse Manager', 'Inventory Manager']],
  [warehouse_supervisor, acme_manufacturing, ['Warehouse Manager']],

  # Procurement Specialist - Cross-company procurement
  [procurement_specialist, acme_manufacturing, ['Procurement Manager']],
  [procurement_specialist, acme_retail, ['Procurement Manager']],
  [procurement_specialist, acme_wholesale, ['Procurement Manager']],

  # Wholesale Director - Wholesale operations
  [wholesale_director, acme_wholesale, ['Wholesale Manager', 'Sales Manager']],
  [wholesale_director, acme_retail, ['Manager']]
]

company_assignments.each do |user, company, role_names|
  company_user = CompanyUser.find_or_create_by!(user: user, company: company)
  role_names.each do |role_name|
    role = find_company_role(company, role_name)
    company_user.company_roles << role unless company_user.company_roles.include?(role)
  end
end

# Generate and cache permissions hash
puts "\n🔧 Generating RBAC permissions cache..."

permissions_hash = {
  'permissions' => {
    'last_update' => Time.now.to_i,
    # Owner role (ID: 1) - Super Admin with full access
    '1' => [
      'accounting/*:*',
      'inventory/*:*', 
      'procurement/*:*',
      'sales/*:*',
      'retail/*:*',
      'warehouse/*:*',
      'wholesale/*:*',
      'users/*:*',
      'companies/*:*'
    ],
    # Admin role (ID: 2) - Company Group Admin
    '2' => [
      'accounting/*:*',
      'inventory/*:*',
      'procurement/*:*',
      'sales/*:*',
      'retail/*:*',
      'warehouse/*:*',
      'wholesale/*:*'
    ],
    # CFO role (ID: 3) - Financial focus
    '3' => [
      'accounting/*:*',
      'accounting/reports:get',
      'accounting/reports:post',
      'accounting/account_receivables:*',
      'accounting/account_payables:*'
    ],
    # Sales Manager (ID: 10)
    '10' => [
      'sales/*:*',
      'sales/leads:*',
      'sales/opportunities:*',
      'sales/customers:*'
    ],
    # Sales Representative (ID: 11) - Limited access
    '11' => [
      'sales/leads:get',
      'sales/leads:post',
      'sales/customers:get',
      '%r{sales/leads/\\d+}:get',
      '%r{sales/leads/\\d+}:put',
      '%r{sales/opportunities/\\d+}:get'
    ],
    # Inventory Manager (ID: 12)
    '12' => [
      'inventory/*:*',
      'warehouse/locations:get',
      'warehouse/shipments:get'
    ],
    # Warehouse Manager (ID: 13)
    '13' => [
      'warehouse/*:*',
      'inventory/products:get',
      'inventory/categories:get'
    ],
    # Procurement Manager (ID: 14)
    '14' => [
      'procurement/*:*',
      'procurement/suppliers:*',
      'procurement/analytics:*'
    ],
    # Retail Manager (ID: 15)
    '15' => [
      'retail/*:*',
      'retail/pos:*',
      'retail/stores:*',
      'sales/customers:get'
    ],
    # Wholesale Manager (ID: 16)
    '16' => [
      'wholesale/*:*',
      'wholesale/bulk_orders:*',
      'wholesale/distributors:*',
      'sales/customers:get'
    ],
    # Accountant (ID: 20) - Limited accounting access
    '20' => [
      'accounting/reports:get',
      'accounting/reports:post',
      'accounting/account_receivables:get',
      'accounting/account_payables:get',
      '%r{accounting/reports/\\d+}:get',
      '%r{accounting/account_receivables/\\d+}:get'
    ],
    # Ordinary Employee (ID: 30) - Minimal access
    '30' => [
      'sales/customers:get'
    ]
  }
}

# Write to Solid Cache with 24-hour expiration
Rails.cache.write("permissions", permissions_hash, expires_in: 24.hours)

puts "✅ Database seeded successfully!"

puts "\n📊 Seed Summary:"
puts "  • Company Group: #{CompanyGroup.count} (#{acme_group.name})"
puts "  • Companies: #{Company.count}"
puts "  • Users: #{User.count}"
puts "  • Company Group Roles: #{CompanyGroupRole.count}"
puts "  • Company Roles: #{CompanyRole.count}"
puts "  • Company User Assignments: #{CompanyUser.count}"

puts "\n🔑 Test Users Created:"
puts "  • owner@acme-corp.com (Super Admin - All Access)"
puts "  • admin@acme-corp.com (Group Admin - Multi-company)"
puts "  • cfo@acme-corp.com (Group CFO - Financial Access)"
puts "  • manager@acme-manufacturing.com (Manufacturing Manager)"
puts "  • manager@acme-retail.com (Retail Manager)"
puts "  • sales@acme-retail.com (Sales Representative - Limited)"
puts "  • lead@acme-tech.com (Tech Lead)"
puts "  • warehouse@acme-logistics.com (Warehouse Supervisor)"
puts "  • procurement@acme-corp.com (Procurement Specialist)"
puts "  • director@acme-wholesale.com (Wholesale Director)"

puts "\n🏢 Companies Available:"
puts "  • acme-manufacturing (Manufacturing)"
puts "  • acme-retail (Retail Operations)"
puts "  • acme-logistics (Logistics & Distribution)"
puts "  • acme-tech (Technology Solutions)"
puts "  • acme-wholesale (Wholesale Distribution)"

puts "\n🎯 RBAC Permissions Cache:"
puts "  • Cache key: 'permissions'"
puts "  • Role permissions: #{permissions_hash['permissions'].keys.count - 1} roles"
puts "  • Cache expiration: 24 hours"
puts "  • Last update: #{permissions_hash['permissions']['last_update']}"

puts "\n📝 All users have password: password123"
puts "🚀 Ready for testing with rack_jwt_aegis!"
