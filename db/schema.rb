# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161129053041) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "admin_birth_day"
    t.integer  "admin_birth_month"
    t.integer  "admin_birth_year"
    t.string   "admin_ssn"
    t.integer  "level"
    t.integer  "company_id"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "admins", ["company_id"], name: "index_admins_on_company_id", using: :btree
  add_index "admins", ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true, using: :btree
  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "company_legal_name"
    t.string   "company_country"
    t.string   "company_business_type"
    t.string   "company_tax_id"
    t.string   "company_street_address"
    t.string   "company_zip"
    t.string   "company_city"
    t.string   "company_website"
    t.string   "company_phone"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "company_iban"
    t.string   "stripe_user_id"
    t.string   "publishable_key"
    t.string   "secret_key"
    t.string   "currency"
    t.string   "stripe_account_type"
    t.string   "stripe_account_status",  default: "{}"
  end

  create_table "court_connectors", force: :cascade do |t|
    t.integer  "court_id"
    t.integer  "shared_court_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "court_connectors", ["court_id"], name: "index_court_connectors_on_court_id", using: :btree
  add_index "court_connectors", ["shared_court_id"], name: "index_court_connectors_on_shared_court_id", using: :btree

  create_table "courts", force: :cascade do |t|
    t.text     "court_description"
    t.integer  "venue_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "duration_policy"
    t.integer  "start_time_policy"
    t.boolean  "active"
    t.boolean  "indoor"
    t.integer  "index"
    t.integer  "sport_name"
    t.boolean  "payment_skippable"
    t.integer  "surface"
  end

  add_index "courts", ["venue_id"], name: "index_courts_on_venue_id", using: :btree

  create_table "day_offs", force: :cascade do |t|
    t.integer  "place_id"
    t.string   "place_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time"
    t.datetime "end_time"
  end

  add_index "day_offs", ["place_type", "place_id"], name: "index_day_offs_on_place_type_and_place_id", using: :btree

  create_table "discount_connections", force: :cascade do |t|
    t.integer  "discount_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "discount_connections", ["discount_id"], name: "index_discount_connections_on_discount_id", using: :btree
  add_index "discount_connections", ["user_id"], name: "index_discount_connections_on_user_id", using: :btree

  create_table "discounts", force: :cascade do |t|
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "venue_id"
    t.integer  "method"
    t.boolean  "round"
  end

  add_index "discounts", ["venue_id"], name: "index_discounts_on_venue_id", using: :btree

  create_table "dividers", force: :cascade do |t|
    t.integer  "price_id"
    t.integer  "court_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "dividers", ["court_id"], name: "index_dividers_on_court_id", using: :btree
  add_index "dividers", ["price_id"], name: "index_dividers_on_price_id", using: :btree

  create_table "email_list_user_connectors", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "email_list_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "email_list_user_connectors", ["email_list_id"], name: "index_email_list_user_connectors_on_email_list_id", using: :btree
  add_index "email_list_user_connectors", ["user_id"], name: "index_email_list_user_connectors_on_user_id", using: :btree

  create_table "email_lists", force: :cascade do |t|
    t.string   "name"
    t.integer  "venue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "email_lists", ["venue_id"], name: "index_email_lists_on_venue_id", using: :btree

  create_table "game_passes", force: :cascade do |t|
    t.integer  "total_charges"
    t.integer  "remaining_charges"
    t.decimal  "price"
    t.boolean  "active",            default: false
    t.integer  "user_id"
    t.integer  "venue_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "is_paid",           default: false
    t.boolean  "is_billed",         default: false
  end

  add_index "game_passes", ["user_id"], name: "index_game_passes_on_user_id", using: :btree
  add_index "game_passes", ["venue_id"], name: "index_game_passes_on_venue_id", using: :btree

  create_table "guests", force: :cascade do |t|
    t.string   "full_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoice_components", force: :cascade do |t|
    t.integer  "reservation_id"
    t.boolean  "is_paid",                                default: false, null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "is_billed",                              default: false, null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal  "price",          precision: 8, scale: 2
    t.integer  "invoice_id"
  end

  add_index "invoice_components", ["invoice_id"], name: "index_invoice_components_on_invoice_id", using: :btree
  add_index "invoice_components", ["reservation_id"], name: "index_invoice_components_on_reservation_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "company_id"
    t.boolean  "is_draft",                                 default: true,  null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.decimal  "total",            precision: 8, scale: 2
    t.integer  "user_id"
    t.boolean  "is_paid",                                  default: false, null: false
    t.string   "reference_number"
    t.datetime "billing_time"
  end

  add_index "invoices", ["company_id"], name: "index_invoices_on_company_id", using: :btree

  create_table "membership_connectors", force: :cascade do |t|
    t.integer  "membership_id"
    t.integer  "reservation_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "membership_connectors", ["membership_id"], name: "index_membership_connectors_on_membership_id", using: :btree
  add_index "membership_connectors", ["reservation_id"], name: "index_membership_connectors_on_reservation_id", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.datetime "end_time"
    t.datetime "start_time"
    t.integer  "user_id"
    t.integer  "venue_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.float    "price"
    t.boolean  "invoice_by_cc",   default: false
    t.string   "subscription_id"
  end

  create_table "photos", force: :cascade do |t|
    t.integer  "venue_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "photos", ["venue_id"], name: "index_photos_on_venue_id", using: :btree

  create_table "prices", force: :cascade do |t|
    t.float    "price"
    t.integer  "court_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "day_of_week"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.integer  "start_minute_of_a_day"
    t.integer  "end_minute_of_a_day"
  end

  add_index "prices", ["court_id"], name: "index_prices_on_court_id", using: :btree

  create_table "reservations", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "date"
    t.decimal  "price"
    t.decimal  "total"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "court_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "is_paid",               default: false, null: false
    t.boolean  "is_billed",             default: false, null: false
    t.string   "user_type"
    t.string   "charge_id"
    t.boolean  "refunded",              default: false
    t.integer  "payment_type"
    t.integer  "booking_type"
    t.integer  "amount_paid"
    t.text     "note"
    t.integer  "initial_membership_id"
    t.boolean  "reselling",             default: false
    t.boolean  "inactive",              default: false
  end

  add_index "reservations", ["user_id"], name: "index_reservations_on_user_id", using: :btree

  create_table "reservations_logs", force: :cascade do |t|
    t.integer  "reservation_id"
    t.integer  "status"
    t.text     "params"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "reservations_logs", ["reservation_id"], name: "index_reservations_logs_on_reservation_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "image"
    t.string   "phone_number"
    t.string   "stripe_id"
    t.string   "street_address"
    t.string   "zipcode"
    t.string   "city"
    t.float    "outstanding_balance"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "venue_user_connectors", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "venue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "venue_user_connectors", ["user_id"], name: "index_venue_user_connectors_on_user_id", using: :btree
  add_index "venue_user_connectors", ["venue_id"], name: "index_venue_user_connectors_on_venue_id", using: :btree

  create_table "venues", force: :cascade do |t|
    t.string   "venue_name"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "description"
    t.text     "parking_info"
    t.text     "transit_info"
    t.string   "website"
    t.string   "phone_number"
    t.integer  "company_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "street"
    t.string   "city"
    t.string   "zip"
    t.integer  "booking_ahead_limit",  default: 365
    t.boolean  "listed",               default: false
    t.text     "business_hours"
    t.integer  "primary_photo_id"
    t.text     "court_counts"
    t.integer  "cancellation_time",    default: 24,    null: false
    t.text     "confirmation_message"
  end

  add_index "venues", ["company_id"], name: "index_venues_on_company_id", using: :btree

  add_foreign_key "admins", "companies"
  add_foreign_key "court_connectors", "courts"
  add_foreign_key "courts", "venues"
  add_foreign_key "discount_connections", "discounts"
  add_foreign_key "discount_connections", "users"
  add_foreign_key "discounts", "venues"
  add_foreign_key "dividers", "courts"
  add_foreign_key "dividers", "prices"
  add_foreign_key "email_list_user_connectors", "email_lists"
  add_foreign_key "email_list_user_connectors", "users"
  add_foreign_key "email_lists", "venues"
  add_foreign_key "game_passes", "users"
  add_foreign_key "game_passes", "venues"
  add_foreign_key "invoice_components", "invoices"
  add_foreign_key "invoice_components", "reservations"
  add_foreign_key "invoices", "companies"
  add_foreign_key "membership_connectors", "memberships"
  add_foreign_key "membership_connectors", "reservations"
  add_foreign_key "photos", "venues"
  add_foreign_key "prices", "courts"
  add_foreign_key "reservations_logs", "reservations"
  add_foreign_key "venue_user_connectors", "users"
  add_foreign_key "venue_user_connectors", "venues"
  add_foreign_key "venues", "companies"
end
