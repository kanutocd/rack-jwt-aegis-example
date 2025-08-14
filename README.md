# RackJwtAegis Multi-Tenant Demo Application

A **basic proof-of-concept** Rails API-only application demonstrating **RackJwtAegis middleware** for multi-tenant JWT authentication and authorization.

**⚠️ Note**: This is an **unfinished demo application** built solely to showcase RackJwtAegis middleware features. It includes only basic API endpoints that return success messages - no actual business logic is implemented.

## What This Demo Shows

This application demonstrates how **RackJwtAegis Rack middleware** validates JWT tokens and enforces multi-tenant security **before requests reach your Rails controllers**:

- ✅ **JWT Token Validation** at middleware layer
- ✅ **Multi-Tenant Isolation** via header validation
- ✅ **Subdomain Authorization** against JWT claims
- ✅ **Path-Based Access Control** using company slugs
- ✅ **Role-Based Permissions** with Solid Cache integration

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   HTTP Request  │───▶│  RackJwtAegis    │───▶│  Rails          │
│                 │    │  Middleware      │    │  Controllers    │
│ JWT + Headers   │    │                  │    │                 │
└─────────────────┘    │ • JWT Validation │    │ • Business      │
                       │ • Tenant Check   │    │   Logic         │
                       │ • Path Auth      │    │ • Response      │
                       │ • RBAC (Part 2)  │    │                 │
                       └──────────────────┘    └─────────────────┘
                              │
                              ▼ (if invalid)
                       ┌──────────────────┐
                       │  HTTP 401/403    │
                       │  Error Response  │
                       └──────────────────┘
```

### Multi-Tenant Structure

```
Company Group (Acme Corporation)
├── acme-manufacturing (Manufacturing)
├── acme-retail (Retail Operations)
├── acme-logistics (Logistics & Distribution)
├── acme-technology (Technology Solutions)
└── acme-wholesale (Wholesale Distribution)

Each company has 7 ERP modules (demo structure only):
📊 Accounting  📦 Inventory  🛒 Procurement  💼 Sales
🏪 Retail     📍 Warehouse  🏭 Wholesale

**Note**: These are placeholder modules for demonstrating multi-tenant routing and permissions - no actual ERP features are implemented.
```

## Quick Start

### 1. Install Dependencies

```bash
bundle install
```

### 2. Setup Database & Seed Data

```bash
rails db:setup
```

This creates:

- **1 Company Group** (Acme Corporation)
- **5 Companies** with different business functions
- **10 Test Users** with various roles and permissions
- **Cached RBAC Permissions** in Solid Cache

### 3. Start Server

```bash
rails server
```

### 4. Test Authentication

```bash
# Login to get JWT token
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "owner@acme-corp.com",
      "password": "password123"
    }
  }'

# Use token for API access (middleware validates before Rails)
curl -X GET http://localhost:3000/api/v1/acme-manufacturing/accounting/reports \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Company-Group-Id: 1"
```

## RackJwtAegis Middleware Configuration

The middleware is configured in `config/application.rb`:

```ruby
config.middleware.insert_before 0, RackJwtAegis::Middleware, {
  jwt_secret: ENV['JWT_SECRET'] || 'your-super-secret-jwt-key-for-development',
  tenant_id_header_name: 'X-Company-Group-Id',
  validate_tenant_id: true,
  validate_pathname_slug: true,
  validate_subdomain: true,
  skip_paths: ['/api/v1/auth/login', '/up', '/api/v1/health'],
  payload_mapping: {
    user_id: :sub,
    tenant_id: :company_group_id,
    subdomain: :company_group_domain,
    pathname_slugs: :company_slugs,
    role_ids: :role_ids,
  },
}
```

## Test Users & Roles

| Email                            | Role            | Companies                          | Access Level                  |
| -------------------------------- | --------------- | ---------------------------------- | ----------------------------- |
| `owner@acme-corp.com`            | Owner           | All                                | Full access (_:_)             |
| `admin@acme-corp.com`            | Admin           | All                                | Multi-company admin           |
| `cfo@acme-corp.com`              | CFO             | All                                | Financial modules             |
| `sales@acme-retail.com`          | Sales Rep       | acme-retail                        | Limited sales access          |
| `manager@acme-manufacturing.com` | Inventory Mgr   | acme-manufacturing, acme-logistics | Inventory + warehouse         |
| `warehouse@acme-logistics.com`   | Warehouse Mgr   | acme-logistics, acme-manufacturing | Warehouse + limited inventory |
| `procurement@acme-corp.com`      | Procurement Mgr | 3 companies                        | Procurement across companies  |

All users have password: `password123`

## API Structure

### Authentication (Public - Skip Middleware)

```
POST /api/v1/auth/login     # User login
POST /api/v1/auth/refresh   # Token refresh
POST /api/v1/auth/logout    # User logout
GET  /up                    # Health check
```

### Multi-Tenant Endpoints (Middleware Protected)

```
/api/v1/{company_slug}/{module}/{resource}

Examples (Demo endpoints - return success messages only):
GET    /api/v1/acme-manufacturing/accounting/reports
POST   /api/v1/acme-retail/sales/customers
PUT    /api/v1/acme-logistics/warehouse/shipments/123
DELETE /api/v1/acme-wholesale/wholesale/distributors/456
```

**Note**: These endpoints only return JSON success messages like `{"message": "Reports retrieved successfully"}` to demonstrate middleware authentication - no actual ERP functionality is implemented.

## Middleware Security Layers

RackJwtAegis validates these layers **before your Rails controllers run**:

### 1. JWT Token Validation

- ✅ Valid signature (HS256)
- ✅ Not expired
- ✅ Proper format

### 2. Tenant Isolation

- ✅ `X-Company-Group-Id` header matches JWT `company_group_id`
- ✅ Request subdomain matches JWT `company_group_domain` (if enabled)

### 3. Path Authorization

- ✅ Company slug in URL exists in JWT `company_slugs` array
- ✅ User has access to that specific company

### 4. Role-Based Access Control (Advanced)

- ✅ Module-level permissions from cached RBAC hash
- ✅ HTTP method validation (GET, POST, PUT, DELETE)
- ✅ Resource-specific access patterns

## Testing the Middleware

### Comprehensive curl Test Suite

See `CURL_TESTING_GUIDE.md` for complete testing scenarios:

```bash
# Test different user roles
./test_owner_access.sh      # Full access
./test_sales_rep_access.sh  # Limited access
./test_cfo_access.sh        # Financial focus

# Test security features
./test_invalid_tokens.sh    # JWT validation
./test_tenant_isolation.sh  # Multi-tenant security
./test_path_authorization.sh # Company access control
```

### Quick Security Tests

```bash
# ❌ No token - rejected by middleware
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/leads

# ❌ Wrong tenant - rejected by middleware
curl -X GET http://localhost:3000/api/v1/acme-retail/sales/leads \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Company-Group-Id: 999"

# ❌ Unauthorized company - rejected by middleware
curl -X GET http://localhost:3000/api/v1/unauthorized-company/sales/leads \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Company-Group-Id: 1"
```

## RBAC Permissions Cache

The application demonstrates advanced RBAC with Solid Cache:

```ruby
# Cached permissions structure
Rails.cache.read("permissions")
# => {
#   "permissions" => {
#     "last_update" => 1755141074,
#     "1" => ["accounting/*:*", "inventory/*:*", "sales/*:*"],  # Owner
#     "11" => ["sales/leads:get", "sales/customers:get"],       # Sales Rep
#     "14" => ["procurement/*:*"]                               # Procurement Manager
#   }
# }
```

## File Structure

```
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb     # JWT payload extraction
│   │   └── api/v1/                       # 7 ERP modules
│   ├── models/
│   │   ├── user.rb                       # JWT payload generation
│   │   ├── company_group.rb              # Top-level tenant
│   │   └── company.rb                    # Sub-level tenant
│   └── services/
│       ├── jwt_service.rb                # Token encoding/decoding
│       └── rbac_permissions_service.rb   # Cached permissions
├── config/
│   ├── application.rb                    # RackJwtAegis middleware config
│   └── routes.rb                         # Multi-tenant routing
├── db/
│   └── seeds.rb                          # Test data + permissions cache
├── CURL_TESTING_GUIDE.md                 # Complete testing scenarios
```

## Development Commands

```bash
# Database
rails db:setup          # Create, migrate, seed with test users
rails db:seed            # Regenerate test data + permissions cache

# Testing
rails test              # Minitest suite
rails test:db           # Reset DB and run tests

# Server
rails server            # Start on port 3000

# Code Quality
bundle exec rubocop     # Linting
bundle exec brakeman    # Security scanning
```

## Articles & Documentation

- **🧪 Testing Guide**: [CURL_TESTING_GUIDE.md](./CURL_TESTING_GUIDE.md)
- **📦 RubyGems**: [rack_jwt_aegis](https://rubygems.org/gems/rack_jwt_aegis)
- **📖 GitHub**: [RackJwtAegis Repository](https://github.com/kanutocd/rack_jwt_aegis)

## Key Takeaways

1. **Middleware-First Security**: Authentication happens before Rails controllers
2. **Multi-Tenant Isolation**: Header and subdomain validation for tenant security
3. **Path-Based Authorization**: Company slugs control access at middleware level
4. **Cached RBAC**: High-performance role-based permissions with Solid Cache
5. **Demo Purpose**: This application demonstrates middleware features only - not a production ERP system

---

**RackJwtAegis**: Secure your multi-tenant Rails applications at the middleware layer.
