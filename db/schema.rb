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

ActiveRecord::Schema.define(version: 20170112071939) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "employees", force: :cascade do |t|
    t.integer  "school_id"
    t.string   "first_name",      default: "",    null: false
    t.string   "last_name",       default: "",    null: false
    t.string   "middle_name",     default: "",    null: false
    t.string   "prefix",          default: "",    null: false
    t.integer  "sex",             default: 0,     null: false
    t.string   "position",        default: ""
    t.string   "personal_id",     default: ""
    t.string   "passport_number", default: ""
    t.string   "race",            default: ""
    t.string   "nationality",     default: ""
    t.string   "bank_name",       default: ""
    t.string   "bank_branch",     default: ""
    t.string   "account_number",  default: ""
    t.decimal  "salary",          default: "0.0", null: false
    t.string   "img_url",         default: ""
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "first_name_thai"
    t.string   "last_name_thai"
    t.string   "prefix_thai"
    t.string   "nickname"
    t.datetime "start_date"
    t.boolean  "deleted",         default: false
    t.datetime "birthdate"
    t.index ["school_id"], name: "index_employees_on_school_id", using: :btree
  end

  create_table "payrolls", force: :cascade do |t|
    t.integer  "employee_id"
    t.decimal  "salary",             default: "0.0",                 null: false
    t.decimal  "allowance",          default: "0.0",                 null: false
    t.decimal  "attendance_bonus",   default: "0.0",                 null: false
    t.decimal  "ot",                 default: "0.0",                 null: false
    t.decimal  "bonus",              default: "0.0",                 null: false
    t.decimal  "position_allowance", default: "0.0",                 null: false
    t.decimal  "extra_etc",          default: "0.0",                 null: false
    t.decimal  "absence",            default: "0.0",                 null: false
    t.decimal  "late",               default: "0.0",                 null: false
    t.decimal  "tax",                default: "0.0",                 null: false
    t.decimal  "social_insurance",   default: "0.0",                 null: false
    t.decimal  "fee_etc",            default: "0.0",                 null: false
    t.decimal  "pvf",                default: "0.0",                 null: false
    t.decimal  "advance_payment",    default: "0.0",                 null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.datetime "effective_date",     default: '2017-01-12 07:29:09', null: false
    t.index ["employee_id"], name: "index_payrolls_on_employee_id", using: :btree
  end

  create_table "schools", force: :cascade do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
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
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "school_id"
    t.string   "name"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["school_id"], name: "index_users_on_school_id", using: :btree
  end

  add_foreign_key "users", "schools"
end
