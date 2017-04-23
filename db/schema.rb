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

ActiveRecord::Schema.define(version: 20170421030721) do

  create_table "merchants", force: :cascade do |t|
    t.string  "full_name"
    t.string  "short_name"
    t.string  "service_tel"
    t.string  "business_category"
    t.text    "memo"
    t.string  "lic_number"
    t.string  "jp_name"
    t.string  "jp_id_number"
    t.string  "contact_name"
    t.string  "contact_tel"
    t.string  "contact_email"
    t.string  "province"
    t.string  "urbn"
    t.string  "city_area"
    t.text    "address"
    t.string  "channel_code"
    t.string  "app_id"
    t.string  "merchant_type"
    t.string  "contact_mobile"
    t.integer "status",            default: 0
    t.string  "mch_id"
    t.string  "chnl_id"
    t.string  "bank_account"
    t.string  "lics"
    t.string  "name"
    t.string  "owner_name"
    t.string  "bank_name"
    t.string  "bank_sub_code"
    t.string  "account_num"
    t.integer "user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "roles_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

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
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
