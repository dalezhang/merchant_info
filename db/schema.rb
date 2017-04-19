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

ActiveRecord::Schema.define(version: 20161118022816) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "product_drafts", force: :cascade do |t|
    t.integer  "user_id",                              null: false
    t.string   "product_code",         default: ""
    t.string   "name",                 default: "",    null: false
    t.string   "category",             default: ""
    t.string   "shop_by_room",         default: ""
    t.string   "brand_name",           default: ""
    t.string   "brand_origin",         default: ""
    t.integer  "delivery_left_bound"
    t.integer  "delivery_right_bound"
    t.string   "bio",                  default: ""
    t.text     "description",          default: ""
    t.string   "link",                 default: ""
    t.integer  "base_followers_count", default: 0
    t.string   "buyer",                default: ""
    t.string   "warehouse",            default: ""
    t.string   "remark",               default: ""
    t.boolean  "examine",              default: false
    t.jsonb    "validation_errors",    default: {}
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "product_drafts", ["brand_name"], name: "index_product_darfts_on_brand_name", using: :btree
  add_index "product_drafts", ["category"], name: "index_product_darfts_on_category", using: :btree
  add_index "product_drafts", ["user_id"], name: "index_product_darfts_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "variants", force: :cascade do |t|
    t.integer  "product_draft_id"
    t.integer  "user_id"
    t.string   "sku"
    t.decimal  "retail_price"
    t.decimal  "price"
    t.decimal  "cost_price"
    t.string   "color"
    t.string   "size"
    t.decimal  "weight"
    t.decimal  "height"
    t.decimal  "width"
    t.decimal  "depth"
    t.jsonb    "sku_attributes"
    t.jsonb    "validation_errors", default: {}
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "variants", ["product_draft_id"], name: "index_variants_on_product_draft_id", using: :btree
  add_index "variants", ["sku"], name: "index_variants_on_sku", using: :btree
  add_index "variants", ["user_id"], name: "index_variants_on_user_id", using: :btree

end
