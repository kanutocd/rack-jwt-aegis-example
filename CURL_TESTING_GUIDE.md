# 🚀 RackJwtAegis Testing Guide with curl

## Prerequisites

1. **Setup Database:**
```bash
rails db:setup  # Creates database, runs migrations, and seeds data
```

2. **Start Server:**
```bash
rails server  # Runs on http://localhost:3000
```

## 🔑 Authentication Tests

### 1. Login as Super Admin (Owner - Role ID: 1)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "owner@acme-corp.com",
      "password": "password123"
    }
  }'
```

### 2. Login as Group Admin (Admin - Role ID: 2)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "admin@acme-corp.com",
      "password": "password123"
    }
  }'
```

### 3. Login as Group CFO (CFO - Role ID: 3)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "cfo@acme-corp.com",
      "password": "password123"
    }
  }'
```

### 4. Login as Manufacturing Manager (Inventory Manager - Role ID: 12)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "manager@acme-manufacturing.com",
      "password": "password123"
    }
  }'
```

### 5. Login as Retail Manager (Retail Manager - Role ID: 15)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "manager@acme-retail.com",
      "password": "password123"
    }
  }'
```

### 6. Login as Sales Representative (Sales Rep - Role ID: 11)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "sales@acme-retail.com",
      "password": "password123"
    }
  }'
```

### 7. Login as Warehouse Supervisor (Warehouse Manager - Role ID: 13)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "warehouse@acme-logistics.com",
      "password": "password123"
    }
  }'
```

### 8. Login as Procurement Specialist (Procurement Manager - Role ID: 14)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "procurement@acme-corp.com",
      "password": "password123"
    }
  }'
```

### 9. Login as Wholesale Director (Wholesale Manager - Role ID: 16)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "director@acme-wholesale.com",
      "password": "password123"
    }
  }'
```

### 10. Login as Tech Lead (Admin - Role ID: 2)
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "lead@acme-tech.com",
      "password": "password123"
    }
  }'
```

---

## 🏢 Multi-Tenant Access Tests Based on Role Permissions

**Save the JWT tokens from login responses for the following tests.**

### Test 1: Owner (Role ID: 1) - Full Access to Everything
```bash
# Extract Owner token
OWNER_TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "owner@acme-corp.com", "password": "password123"}}' | jq -r '.token')

# ✅ ALLOWED: Owner can access any module in any company
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/accounting/reports \
  -H "Authorization: Bearer $OWNER_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-retail/sales/customers \
  -H "Authorization: Bearer $OWNER_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-tech/inventory/products \
  -H "Authorization: Bearer $OWNER_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-wholesale/wholesale/distributors \
  -H "Authorization: Bearer $OWNER_TOKEN" -H "X-Company-Group-Id: 1"
```

### Test 2: CFO (Role ID: 3) - Financial Focus
```bash
# Extract CFO token
CFO_TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "cfo@acme-corp.com", "password": "password123"}}' | jq -r '.token')

# ✅ ALLOWED: CFO can access accounting across companies
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/accounting/reports \
  -H "Authorization: Bearer $CFO_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-retail/accounting/account_receivables \
  -H "Authorization: Bearer $CFO_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-tech/accounting/account_payables \
  -H "Authorization: Bearer $CFO_TOKEN" -H "X-Company-Group-Id: 1"

# ❌ FORBIDDEN: CFO trying to access non-financial modules (if not explicitly allowed)
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/leads \
  -H "Authorization: Bearer $CFO_TOKEN" -H "X-Company-Group-Id: 1"
```

### Test 3: Sales Representative (Role ID: 11) - Limited Sales Access
```bash
# Extract Sales Rep token
SALES_TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "sales@acme-retail.com", "password": "password123"}}' | jq -r '.token')

# ✅ ALLOWED: Sales rep accessing retail sales (limited permissions)
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/leads \
  -H "Authorization: Bearer $SALES_TOKEN" -H "X-Company-Group-Id: 1"

curl -X POST http://localhost:3000/api/v1/acme-retail/sales/leads \
  -H "Authorization: Bearer $SALES_TOKEN" -H "X-Company-Group-Id: 1" \
  -H "Content-Type: application/json" -d '{"name": "Test Lead"}'

curl -X GET http://localhost:3000/api/v1/acme-retail/sales/customers \
  -H "Authorization: Bearer $SALES_TOKEN" -H "X-Company-Group-Id: 1"

# ❌ FORBIDDEN: Sales rep trying to access other companies
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/inventory/products \
  -H "Authorization: Bearer $SALES_TOKEN" -H "X-Company-Group-Id: 1"

# ❌ FORBIDDEN: Sales rep trying to access accounting
curl -X GET http://localhost:3000/api/v1/acme-retail/accounting/reports \
  -H "Authorization: Bearer $SALES_TOKEN" -H "X-Company-Group-Id: 1"
```

### Test 4: Inventory Manager (Role ID: 12) - Inventory + Limited Warehouse
```bash
# Extract Inventory Manager token
INVENTORY_TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "manager@acme-manufacturing.com", "password": "password123"}}' | jq -r '.token')

# ✅ ALLOWED: Inventory manager accessing inventory (full access)
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/inventory/products \
  -H "Authorization: Bearer $INVENTORY_TOKEN" -H "X-Company-Group-Id: 1"

curl -X POST http://localhost:3000/api/v1/acme-manufacturing/inventory/categories \
  -H "Authorization: Bearer $INVENTORY_TOKEN" -H "X-Company-Group-Id: 1" \
  -H "Content-Type: application/json" -d '{"name": "Test Category"}'

# ✅ ALLOWED: Limited warehouse access
curl -X GET http://localhost:3000/api/v1/acme-logistics/warehouse/locations \
  -H "Authorization: Bearer $INVENTORY_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-manufacturing/warehouse/shipments \
  -H "Authorization: Bearer $INVENTORY_TOKEN" -H "X-Company-Group-Id: 1"

# ❌ FORBIDDEN: Inventory manager trying to access sales
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/sales/customers \
  -H "Authorization: Bearer $INVENTORY_TOKEN" -H "X-Company-Group-Id: 1"
```

### Test 5: Warehouse Manager (Role ID: 13) - Warehouse + Limited Inventory
```bash
# Extract Warehouse Manager token
WAREHOUSE_TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "warehouse@acme-logistics.com", "password": "password123"}}' | jq -r '.token')

# ✅ ALLOWED: Warehouse manager accessing warehouse (full access)
curl -X GET http://localhost:3000/api/v1/acme-logistics/warehouse/locations \
  -H "Authorization: Bearer $WAREHOUSE_TOKEN" -H "X-Company-Group-Id: 1"

curl -X POST http://localhost:3000/api/v1/acme-logistics/warehouse/shipments \
  -H "Authorization: Bearer $WAREHOUSE_TOKEN" -H "X-Company-Group-Id: 1" \
  -H "Content-Type: application/json" -d '{"destination": "Test Location"}'

# ✅ ALLOWED: Limited inventory access (read-only)
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/inventory/products \
  -H "Authorization: Bearer $WAREHOUSE_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-logistics/inventory/categories \
  -H "Authorization: Bearer $WAREHOUSE_TOKEN" -H "X-Company-Group-Id: 1"

# ❌ FORBIDDEN: Warehouse manager trying to access accounting
curl -X GET http://localhost:3000/api/v1/acme-logistics/accounting/reports \
  -H "Authorization: Bearer $WAREHOUSE_TOKEN" -H "X-Company-Group-Id: 1"
```

### Test 6: Procurement Manager (Role ID: 14) - Multi-Company Procurement
```bash
# Extract Procurement Manager token
PROCUREMENT_TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "procurement@acme-corp.com", "password": "password123"}}' | jq -r '.token')

# ✅ ALLOWED: Procurement across assigned companies
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/procurement/suppliers \
  -H "Authorization: Bearer $PROCUREMENT_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-retail/procurement/analytics \
  -H "Authorization: Bearer $PROCUREMENT_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-wholesale/procurement/suppliers \
  -H "Authorization: Bearer $PROCUREMENT_TOKEN" -H "X-Company-Group-Id: 1"

# ❌ FORBIDDEN: Procurement trying to access non-assigned company
curl -X GET http://localhost:3000/api/v1/acme-tech/procurement/suppliers \
  -H "Authorization: Bearer $PROCUREMENT_TOKEN" -H "X-Company-Group-Id: 1"
```

### Test 7: Retail Manager (Role ID: 15) - Retail Operations
```bash
# Extract Retail Manager token
RETAIL_TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "manager@acme-retail.com", "password": "password123"}}' | jq -r '.token')

# ✅ ALLOWED: Retail operations (full access)
curl -X GET http://localhost:3000/api/v1/acme-retail/retail/pos \
  -H "Authorization: Bearer $RETAIL_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-retail/retail/stores \
  -H "Authorization: Bearer $RETAIL_TOKEN" -H "X-Company-Group-Id: 1"

# ✅ ALLOWED: Sales customers (limited access)
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/customers \
  -H "Authorization: Bearer $RETAIL_TOKEN" -H "X-Company-Group-Id: 1"

# ❌ FORBIDDEN: Retail manager trying to access manufacturing
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/inventory/products \
  -H "Authorization: Bearer $RETAIL_TOKEN" -H "X-Company-Group-Id: 1"
```

### Test 8: Wholesale Manager (Role ID: 16) - Wholesale Operations
```bash
# Extract Wholesale Manager token
WHOLESALE_TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "director@acme-wholesale.com", "password": "password123"}}' | jq -r '.token')

# ✅ ALLOWED: Wholesale operations (full access)
curl -X GET http://localhost:3000/api/v1/acme-wholesale/wholesale/bulk_orders \
  -H "Authorization: Bearer $WHOLESALE_TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-wholesale/wholesale/distributors \
  -H "Authorization: Bearer $WHOLESALE_TOKEN" -H "X-Company-Group-Id: 1"

# ✅ ALLOWED: Sales customers (limited access)
curl -X GET http://localhost:3000/api/v1/acme-wholesale/sales/customers \
  -H "Authorization: Bearer $WHOLESALE_TOKEN" -H "X-Company-Group-Id: 1"

# Also has Manager access to retail company
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/customers \
  -H "Authorization: Bearer $WHOLESALE_TOKEN" -H "X-Company-Group-Id: 1"

# ❌ FORBIDDEN: Wholesale manager trying to access accounting
curl -X GET http://localhost:3000/api/v1/acme-wholesale/accounting/reports \
  -H "Authorization: Bearer $WHOLESALE_TOKEN" -H "X-Company-Group-Id: 1"
```

---

## 🎯 Testing Against Cached Permissions

You can verify that the role-based permissions match the cached permissions hash:

### Check Cached Permissions
```bash
# Start Rails console to check cached permissions
rails console

# In console:
cached_permissions = Rails.cache.read("permissions")
puts JSON.pretty_generate(cached_permissions)

# Check specific role permissions
puts "Owner permissions (Role ID: 1):"
cached_permissions['permissions']['1'].each { |perm| puts "  #{perm}" }

puts "Sales Rep permissions (Role ID: 11):"
cached_permissions['permissions']['11'].each { |perm| puts "  #{perm}" }
```

### Quick Verification Script
```bash
# Create a verification script
cat > test_permissions.rb << 'EOF'
require_relative 'config/environment'

cached_permissions = Rails.cache.read("permissions")
if cached_permissions
  puts "✅ Permissions cache found"
  puts "📅 Last update: #{Time.at(cached_permissions['permissions']['last_update'])}"
  puts "🔑 Total roles: #{cached_permissions['permissions'].keys.count - 1}"
  
  # Test specific role permissions
  role_11_perms = cached_permissions['permissions']['11']
  puts "\n🎯 Sales Rep (Role 11) permissions:"
  role_11_perms.each { |perm| puts "  #{perm}" }
  
  # Verify sales rep can access sales but not accounting
  sales_allowed = role_11_perms.any? { |p| p.include?('sales/leads:get') }
  accounting_forbidden = !role_11_perms.any? { |p| p.include?('accounting/') }
  
  puts "\n✅ Sales Rep can access sales/leads:get: #{sales_allowed}"
  puts "✅ Sales Rep cannot access accounting: #{accounting_forbidden}"
else
  puts "❌ No permissions cache found"
end
EOF

# Run the verification
bundle exec ruby test_permissions.rb
```

### Permission Matrix Summary

Based on the cached permissions hash, here's the access matrix:

| Role ID | Role Name | Companies | Modules | Permissions Level |
|---------|-----------|-----------|---------|-------------------|
| 1 | Owner | All | All | Full (*:*) |
| 2 | Admin | All | All | Full (*:*) |
| 3 | CFO | All | Accounting | Full accounting + limited |
| 11 | Sales Rep | acme-retail | Sales | Limited (get, post, specific regex) |
| 12 | Inventory Mgr | acme-manufacturing, acme-logistics | Inventory, Warehouse | Full inventory, limited warehouse |
| 13 | Warehouse Mgr | acme-logistics, acme-manufacturing | Warehouse, Inventory | Full warehouse, limited inventory |
| 14 | Procurement Mgr | acme-manufacturing, acme-retail, acme-wholesale | Procurement | Full procurement |
| 15 | Retail Mgr | acme-retail | Retail, Sales | Full retail, limited sales |
| 16 | Wholesale Mgr | acme-wholesale, acme-retail | Wholesale, Sales | Full wholesale, limited sales |

---

## 🛡️ RackJwtAegis Security Features Demo

### Feature 1: JWT Token Validation
```bash
# ❌ UNAUTHORIZED: No token provided
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/leads \
  -H "X-Company-Group-Id: 1"

# ❌ UNAUTHORIZED: Invalid token
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/leads \
  -H "Authorization: Bearer invalid.jwt.token" \
  -H "X-Company-Group-Id: 1"

# ❌ UNAUTHORIZED: Malformed token
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/leads \
  -H "Authorization: Bearer notjwttoken" \
  -H "X-Company-Group-Id: 1"
```

### Feature 2: Tenant Isolation
```bash
# ❌ FORBIDDEN: Valid token but wrong tenant header
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/leads \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Company-Group-Id: 999"

# ❌ FORBIDDEN: Valid token but missing tenant header
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/leads \
  -H "Authorization: Bearer $TOKEN"
```

### Feature 3: Path-Based Authorization (Company Slug Validation)
```bash
# ❌ FORBIDDEN: User trying to access company not in their accessible_company_slugs
# (Sales rep trying to access manufacturing when only assigned to retail)
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/inventory/products \
  -H "Authorization: Bearer $SALES_TOKEN" \
  -H "X-Company-Group-Id: 1"
```

### Feature 4: Skip Paths (Public Endpoints)
```bash
# ✅ ALLOWED: Authentication endpoints are public
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "test", "password": "test"}}'

# ✅ ALLOWED: Health check is public
curl -X GET http://localhost:3000/up

curl -X GET http://localhost:3000/api/v1/health
```

---

## 🎯 Role-Based Access Control Tests

### CFO (Financial Access Across Companies)
```bash
# Login as CFO
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "cfo@acme-corp.com",
      "password": "password123"
    }
  }'

# ✅ ALLOWED: CFO accessing accounting across companies
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/accounting/reports \
  -H "Authorization: Bearer $CFO_TOKEN" \
  -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-retail/accounting/account_payables \
  -H "Authorization: Bearer $CFO_TOKEN" \
  -H "X-Company-Group-Id: 1"

# ❌ LIMITED: CFO may have restricted access to non-financial modules
curl -X GET http://localhost:3000/api/v1/acme-tech/sales/leads \
  -H "Authorization: Bearer $CFO_TOKEN" \
  -H "X-Company-Group-Id: 1"
```

### Procurement Specialist (Cross-Company Procurement)
```bash
# Login as Procurement Specialist
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "procurement@acme-corp.com",
      "password": "password123"
    }
  }'

# ✅ ALLOWED: Procurement specialist accessing procurement across assigned companies
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/procurement/suppliers \
  -H "Authorization: Bearer $PROCUREMENT_TOKEN" \
  -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-wholesale/procurement/analytics \
  -H "Authorization: Bearer $PROCUREMENT_TOKEN" \
  -H "X-Company-Group-Id: 1"

# ❌ FORBIDDEN: Accessing companies they're not assigned to
curl -X GET http://localhost:3000/api/v1/acme-tech/procurement/suppliers \
  -H "Authorization: Bearer $PROCUREMENT_TOKEN" \
  -H "X-Company-Group-Id: 1"
```

---

## 🔄 CRUD Operations Testing

### Test All CRUD Operations (with Super Admin token)
```bash
# CREATE
curl -X POST http://localhost:3000/api/v1/acme-manufacturing/inventory/products \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "X-Company-Group-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{"name": "New Product"}'

# READ (Index)
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/inventory/products \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "X-Company-Group-Id: 1"

# READ (Show)
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/inventory/products/123 \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "X-Company-Group-Id: 1"

# UPDATE
curl -X PUT http://localhost:3000/api/v1/acme-manufacturing/inventory/products/123 \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "X-Company-Group-Id: 1" \
  -H "Content-Type: application/json" \
  -d '{"name": "Updated Product"}'

# DELETE
curl -X DELETE http://localhost:3000/api/v1/acme-manufacturing/inventory/products/123 \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "X-Company-Group-Id: 1"
```

---

## 📊 All Module Access Tests

Test access to all 7 ERP modules with different users:

### Accounting Module
```bash
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/accounting/reports \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-retail/accounting/account_receivables \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-tech/accounting/account_payables \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"
```

### Inventory Module
```bash
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/inventory/products \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-retail/inventory/categories \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"
```

### Procurement Module
```bash
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/procurement/suppliers \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-wholesale/procurement/analytics \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"
```

### Sales Module
```bash
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/leads \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-wholesale/sales/opportunities \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-retail/sales/customers \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"
```

### Retail Module
```bash
curl -X GET http://localhost:3000/api/v1/acme-retail/retail/pos \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-retail/retail/stores \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"
```

### Warehouse Module
```bash
curl -X GET http://localhost:3000/api/v1/acme-logistics/warehouse/locations \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-manufacturing/warehouse/shipments \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"
```

### Wholesale Module
```bash
curl -X GET http://localhost:3000/api/v1/acme-wholesale/wholesale/bulk_orders \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"

curl -X GET http://localhost:3000/api/v1/acme-wholesale/wholesale/distributors \
  -H "Authorization: Bearer $TOKEN" -H "X-Company-Group-Id: 1"
```

---

## 🧪 Advanced Security Tests

### Test JWT Token Refresh
```bash
# Refresh token
curl -X POST http://localhost:3000/api/v1/auth/refresh \
  -H "Authorization: Bearer $EXISTING_TOKEN" \
  -H "X-Company-Group-Id: 1"
```

### Test Token Logout
```bash
# Logout (invalidate token)
curl -X POST http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Company-Group-Id: 1"
```

### Test Invalid Company Slug
```bash
# ❌ FORBIDDEN: Valid token but invalid company slug
curl -X GET http://localhost:3000/api/v1/invalid-company/sales/leads \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Company-Group-Id: 1"
```

---

## 🎉 RackJwtAegis Superpower Demonstration Summary

The tests above demonstrate these **RackJwtAegis superpowers**:

1. **🔐 JWT Authentication**: Validates JWT tokens with proper secret and algorithm
2. **🏢 Multi-Tenant Isolation**: Header-based tenant validation (`X-Company-Group-Id`)
3. **📍 Path-Based Authorization**: Company slug validation from JWT `accessible_company_slugs`
4. **👥 Role-Based Access Control**: User roles determine module/company access
5. **🛡️ Payload Validation**: Custom business logic validation in JWT payload
6. **🚫 Skip Paths**: Public endpoints bypass authentication
7. **⚡ Performance**: Caching layer for permissions with Solid Cache
8. **🔄 Token Management**: Login, refresh, and logout capabilities
9. **📊 Comprehensive Coverage**: All CRUD operations across 7 ERP modules
10. **🏗️ Scalable Architecture**: Support for complex enterprise hierarchies

### Quick Test Script
Save this as `test_rack_jwt_aegis.sh`:
```bash
#!/bin/bash
BASE_URL="http://localhost:3000"

echo "🚀 Testing RackJwtAegis Superpowers..."

# Test 1: Login as Super Admin
echo "1️⃣ Super Admin Login..."
ADMIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "owner@acme-corp.com", "password": "password123"}}')
ADMIN_TOKEN=$(echo $ADMIN_RESPONSE | jq -r '.token')
echo "Token: ${ADMIN_TOKEN:0:50}..."

# Test 2: Access with proper auth
echo "2️⃣ Authorized Access Test..."
curl -s -X GET $BASE_URL/api/v1/acme-manufacturing/accounting/reports \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "X-Company-Group-Id: 1" | jq '.message'

# Test 3: Access without auth (should fail)
echo "3️⃣ Unauthorized Access Test..."
curl -s -X GET $BASE_URL/api/v1/acme-manufacturing/accounting/reports | jq '.error // "No error field"'

echo "✅ RackJwtAegis tests complete!"
```

Run with: `chmod +x test_rack_jwt_aegis.sh && ./test_rack_jwt_aegis.sh`