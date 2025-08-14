# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_13_095125) do
  create_table "addresses", force: :cascade do |t|
    t.string "street_line_1"
    t.string "street_line_2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country"
    t.string "addressable_type", null: false
    t.integer "addressable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "company_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_group_id"], name: "index_companies_on_company_group_id"
    t.index ["name", "company_group_id"], name: "index_companies_on_name_and_company_group_id", unique: true
    t.index ["slug", "company_group_id"], name: "index_companies_on_slug_and_company_group_id", unique: true
  end

  create_table "company_group_roles", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "company_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_group_id"], name: "index_company_group_roles_on_company_group_id"
    t.index ["name", "company_group_id"], name: "index_company_group_roles_on_name_and_company_group_id", unique: true
  end

  create_table "company_group_roles_users", id: false, force: :cascade do |t|
    t.integer "company_group_role_id", null: false
    t.integer "user_id", null: false
    t.index ["company_group_role_id"], name: "index_company_group_roles_users_on_company_group_role_id"
    t.index ["user_id"], name: "index_company_group_roles_users_on_user_id"
  end

  create_table "company_groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "domain_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_name"], name: "index_company_groups_on_domain_name", unique: true
  end

  create_table "company_roles", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_roles_on_company_id"
    t.index ["name", "company_id"], name: "index_company_roles_on_name_and_company_id", unique: true
  end

  create_table "company_roles_users", id: false, force: :cascade do |t|
    t.integer "company_role_id", null: false
    t.integer "company_user_id", null: false
    t.index ["company_role_id"], name: "index_company_roles_users_on_company_role_id"
    t.index ["company_user_id"], name: "index_company_roles_users_on_company_user_id"
  end

  create_table "company_users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_users_on_company_id"
    t.index ["user_id", "company_id"], name: "index_company_users_on_user_id_and_company_id", unique: true
    t.index ["user_id"], name: "index_company_users_on_user_id"
  end

  create_table "email_addresses", force: :cascade do |t|
    t.string "email"
    t.string "label"
    t.string "emailable_type", null: false
    t.integer "emailable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emailable_type", "emailable_id"], name: "index_email_addresses_on_emailable"
  end

  create_table "phones", force: :cascade do |t|
    t.string "phone_number"
    t.string "extension"
    t.string "phone_type"
    t.string "label"
    t.string "phoneable_type", null: false
    t.integer "phoneable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phoneable_type", "phoneable_id"], name: "index_phones_on_phoneable"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", limit: 1024, null: false
    t.binary "value", limit: 536870912, null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "middle_name"
    t.integer "company_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_group_id"], name: "index_users_on_company_group_id"
    t.index ["email", "company_group_id"], name: "index_users_on_email_and_company_group_id", unique: true
  end

  create_table "websites", force: :cascade do |t|
    t.string "url"
    t.string "label"
    t.string "websitable_type", null: false
    t.integer "websitable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["websitable_type", "websitable_id"], name: "index_websites_on_websitable"
  end

  add_foreign_key "companies", "company_groups"
  add_foreign_key "company_group_roles", "company_groups"
  add_foreign_key "company_roles", "companies"
  add_foreign_key "company_users", "companies"
  add_foreign_key "company_users", "users"
  add_foreign_key "users", "company_groups"
end
