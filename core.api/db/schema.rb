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

ActiveRecord::Schema.define(version: 20150325112800) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

# Could not dump table "companies" because of following StandardError
#   Unknown type 'company_segment' for column 'segment_type'

  create_table "company_metrics_days", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "locked_at"
    t.integer  "company_id",     null: false
    t.datetime "start_datetime", null: false
    t.json     "data_json"
  end

  add_index "company_metrics_days", ["company_id", "start_datetime"], name: "index_company_metrics_days_on_company_id_and_start_datetime", unique: true, using: :btree
  add_index "company_metrics_days", ["company_id"], name: "index_company_metrics_days_on_company_id", using: :btree

  create_table "company_metrics_manual_months", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "company_id",                  null: false
    t.datetime "start_datetime",              null: false
    t.json     "data_json",      default: {}
  end

  add_index "company_metrics_manual_months", ["company_id", "start_datetime"], name: "index_metrics_manual_months_on_company_id_and_start_datetime", unique: true, using: :btree
  add_index "company_metrics_manual_months", ["company_id"], name: "index_company_metrics_manual_months_on_company_id", using: :btree

  create_table "company_metrics_months", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "locked_at"
    t.integer  "company_id",     null: false
    t.datetime "start_datetime", null: false
    t.json     "data_json"
  end

  add_index "company_metrics_months", ["company_id", "start_datetime"], name: "index_company_metrics_months_on_company_id_and_start_datetime", unique: true, using: :btree
  add_index "company_metrics_months", ["company_id"], name: "index_company_metrics_months_on_company_id", using: :btree

  create_table "company_metrics_weeks", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "locked_at"
    t.integer  "company_id",     null: false
    t.datetime "start_datetime", null: false
    t.json     "data_json"
  end

  add_index "company_metrics_weeks", ["company_id", "start_datetime"], name: "index_company_metrics_weeks_on_company_id_and_start_datetime", unique: true, using: :btree
  add_index "company_metrics_weeks", ["company_id"], name: "index_company_metrics_weeks_on_company_id", using: :btree

  create_table "company_metrics_years", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "locked_at"
    t.integer  "company_id",     null: false
    t.datetime "start_datetime", null: false
    t.json     "data_json"
  end

  add_index "company_metrics_years", ["company_id", "start_datetime"], name: "index_company_metrics_years_on_company_id_and_start_datetime", unique: true, using: :btree
  add_index "company_metrics_years", ["company_id"], name: "index_company_metrics_years_on_company_id", using: :btree

  create_table "currency_rates", force: :cascade do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "old_mongoid",    limit: 24
    t.date     "date"
    t.json     "currency_rates"
  end

  add_index "currency_rates", ["date"], name: "index_currency_rates_on_date", unique: true, using: :btree
  add_index "currency_rates", ["old_mongoid"], name: "index_currency_rates_on_old_mongoid", unique: true, using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "user_id"
    t.string   "feedback_type"
    t.string   "feedback_body"
  end

  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id", using: :btree

  create_table "lifestages", force: :cascade do |t|
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "company_id"
    t.decimal  "modeled_lifestage"
    t.integer  "users"
    t.integer  "payers"
    t.integer  "employees"
    t.integer  "engineers"
    t.decimal  "revenue_last_month"
    t.decimal  "expenses_last_month"
    t.decimal  "customer_lifetime"
  end

  add_index "lifestages", ["company_id", "created_at"], name: "index_lifestages_on_company_id_and_created_at", unique: true, using: :btree
  add_index "lifestages", ["company_id"], name: "index_lifestages_on_company_id", using: :btree
  add_index "lifestages", ["modeled_lifestage"], name: "index_lifestages_on_modeled_lifestage", using: :btree

  create_table "saas_connections", force: :cascade do |t|
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "company_id"
    t.string   "service_type"
    t.boolean  "is_valid",                              default: false
    t.text     "encrypted_auth_data_string"
    t.string   "old_mongoid",                limit: 24
    t.text     "old_mongoid_auth_data"
    t.datetime "successfully_used_first"
    t.datetime "successfully_used_last"
    t.integer  "current_error_state"
    t.datetime "current_error_since"
    t.string   "last_error_reason"
    t.datetime "last_error_occurred_at"
    t.string   "invalidation_reason"
    t.datetime "invalidation_at"
  end

  add_index "saas_connections", ["company_id", "service_type", "is_valid"], name: "index_valid_company_service_credentials", using: :btree
  add_index "saas_connections", ["company_id"], name: "index_saas_connections_on_company_id", using: :btree
  add_index "saas_connections", ["old_mongoid"], name: "index_saas_connections_on_old_mongoid", unique: true, using: :btree
  add_index "saas_connections", ["service_type"], name: "index_saas_connections_on_service_type", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.datetime "session_expiry"
    t.string   "old_mongoid",             limit: 24
    t.string   "session_token"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "reset_token"
    t.string   "phone_number"
    t.integer  "number_of_logins",                   default: 0
    t.datetime "last_login_at"
    t.json     "weekly_logins",                      default: {}
    t.integer  "consecutive_weeks_login",            default: 0
    t.string   "onboarding_status"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["old_mongoid"], name: "index_users_on_old_mongoid", unique: true, using: :btree
  add_index "users", ["reset_token"], name: "index_users_on_reset_token", unique: true, using: :btree
  add_index "users", ["session_token"], name: "index_users_on_session_token", using: :btree

  add_foreign_key "companies", "users", on_update: :cascade
  add_foreign_key "company_metrics_days", "companies"
  add_foreign_key "company_metrics_manual_months", "companies", on_update: :cascade
  add_foreign_key "company_metrics_months", "companies"
  add_foreign_key "company_metrics_weeks", "companies"
  add_foreign_key "company_metrics_years", "companies"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "lifestages", "companies", on_update: :cascade
  add_foreign_key "saas_connections", "companies", on_update: :cascade
end
