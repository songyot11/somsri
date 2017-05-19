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

ActiveRecord::Schema.define(version: 20170518103715) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_types", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.string   "name",            limit: 512,                null: false
    t.datetime "date",                                       null: false
    t.integer  "account_type_id",                            null: false
    t.float    "amount",                       default: 0.0, null: false
    t.string   "note",            limit: 1024
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.index ["name"], name: "index_accounts_on_name", using: :btree
  end

  create_table "class_permisions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "list_id"
    t.integer  "user_id"
    t.index ["list_id"], name: "index_class_permisions_on_list_id", using: :btree
    t.index ["user_id"], name: "index_class_permisions_on_user_id", using: :btree
  end

  create_table "daily_reports", force: :cascade do |t|
    t.float    "real_start_cash",  default: 0.0
    t.float    "real_cash",        default: 0.0
    t.float    "real_credit_card", default: 0.0
    t.float    "real_cheque",      default: 0.0
    t.float    "real_tranfers",    default: 0.0
    t.float    "cash",             default: 0.0
    t.float    "credit_card",      default: 0.0
    t.float    "cheque",           default: 0.0
    t.float    "tranfers",         default: 0.0
    t.integer  "user_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "employees", force: :cascade do |t|
    t.integer  "school_id"
    t.string   "first_name",           default: "",             null: false
    t.string   "last_name",            default: "",             null: false
    t.string   "middle_name",          default: "",             null: false
    t.string   "prefix",               default: "",             null: false
    t.integer  "sex",                  default: 0,              null: false
    t.string   "position",             default: ""
    t.string   "personal_id",          default: ""
    t.string   "passport_number",      default: ""
    t.string   "race",                 default: ""
    t.string   "nationality",          default: ""
    t.string   "bank_name",            default: ""
    t.string   "bank_branch",          default: ""
    t.string   "account_number",       default: ""
    t.decimal  "salary",               default: "0.0",          null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "first_name_thai"
    t.string   "last_name_thai"
    t.string   "prefix_thai"
    t.string   "nickname"
    t.datetime "start_date"
    t.datetime "birthdate"
    t.text     "address"
    t.string   "tel"
    t.string   "status"
    t.string   "email"
    t.string   "employee_type",        default: "ลูกจ้างประจำ", null: false
    t.boolean  "pay_social_insurance"
    t.boolean  "pay_pvf"
    t.string   "pin"
    t.integer  "grade_id"
    t.string   "classroom"
    t.string   "img_url_file_name"
    t.string   "img_url_content_type"
    t.integer  "img_url_file_size"
    t.datetime "img_url_updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_employees_on_deleted_at", using: :btree
    t.index ["school_id"], name: "index_employees_on_school_id", using: :btree
  end

  create_table "genders", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grades", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "individuals", force: :cascade do |t|
    t.string   "prefix"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "first_name_thai"
    t.string   "last_name_thai"
    t.string   "prefix_thai"
    t.string   "personal_id"
    t.string   "passport_number"
    t.string   "race"
    t.string   "nationality"
    t.string   "phone"
    t.string   "email"
    t.string   "relationship"
    t.datetime "birthdate"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "emergency_call_id"
    t.integer  "spouse_id"
    t.integer  "child_id"
    t.integer  "parent_id"
    t.integer  "friend_id"
    t.index ["child_id"], name: "index_individuals_on_child_id", using: :btree
    t.index ["emergency_call_id"], name: "index_individuals_on_emergency_call_id", using: :btree
    t.index ["friend_id"], name: "index_individuals_on_friend_id", using: :btree
    t.index ["parent_id"], name: "index_individuals_on_parent_id", using: :btree
    t.index ["spouse_id"], name: "index_individuals_on_spouse_id", using: :btree
  end

  create_table "invoice_statuses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.text     "remark"
    t.string   "payment_method_id"
    t.string   "cheque_bank_name"
    t.string   "cheque_number"
    t.string   "cheque_date"
    t.string   "transfer_bank_name"
    t.string   "transfer_date"
    t.integer  "invoice_status_id"
    t.string   "school_year"
    t.string   "semester"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "grade_name"
  end

  create_table "line_items", force: :cascade do |t|
    t.string   "detail"
    t.float    "amount"
    t.integer  "invoice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lists", force: :cascade do |t|
    t.string   "name",       default: "", null: false
    t.string   "category",   default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "parents", force: :cascade do |t|
    t.string   "full_name"
    t.string   "full_name_english"
    t.string   "nickname"
    t.string   "nickname_english"
    t.string   "mobile"
    t.string   "email"
    t.string   "line_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "id_card_no"
    t.datetime "deleted_at"
    t.string   "img_url_file_name"
    t.string   "img_url_content_type"
    t.integer  "img_url_file_size"
    t.datetime "img_url_updated_at"
    t.index ["deleted_at"], name: "index_parents_on_deleted_at", using: :btree
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string  "payment_method"
    t.string  "cheque_bank_name"
    t.string  "cheque_number"
    t.string  "cheque_date"
    t.string  "transfer_bank_name"
    t.string  "transfer_date"
    t.integer "invoice_id"
    t.float   "amount",             default: 0.0, null: false
  end

  create_table "payrolls", force: :cascade do |t|
    t.integer  "employee_id"
    t.decimal  "salary",             default: "0.0", null: false
    t.decimal  "allowance",          default: "0.0", null: false
    t.decimal  "attendance_bonus",   default: "0.0", null: false
    t.decimal  "ot",                 default: "0.0", null: false
    t.decimal  "bonus",              default: "0.0", null: false
    t.decimal  "position_allowance", default: "0.0", null: false
    t.decimal  "extra_etc",          default: "0.0", null: false
    t.decimal  "absence",            default: "0.0", null: false
    t.decimal  "late",               default: "0.0", null: false
    t.decimal  "tax",                default: "0.0", null: false
    t.decimal  "social_insurance",   default: "0.0", null: false
    t.decimal  "fee_etc",            default: "0.0", null: false
    t.decimal  "pvf",                default: "0.0", null: false
    t.decimal  "advance_payment",    default: "0.0", null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.datetime "effective_date",                     null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_payrolls_on_deleted_at", using: :btree
    t.index ["employee_id"], name: "index_payrolls_on_employee_id", using: :btree
  end

  create_table "relationships", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "roll_calls", force: :cascade do |t|
    t.integer  "student_id"
    t.string   "status",     default: "", null: false
    t.string   "cause",      default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "round"
    t.string   "check_date"
    t.integer  "list_id"
    t.index ["list_id"], name: "index_roll_calls_on_list_id", using: :btree
    t.index ["student_id", "list_id", "check_date", "round"], name: "index_roll_calls_uniq_roll", unique: true, using: :btree
    t.index ["student_id"], name: "index_roll_calls_on_student_id", using: :btree
  end

  create_table "schools", force: :cascade do |t|
    t.string   "name",                default: "", null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "tax_id"
    t.string   "address"
    t.string   "zip_code"
    t.string   "phone"
    t.string   "fax"
    t.text     "invoice_header"
    t.string   "email"
    t.text     "daily_report_header"
    t.text     "invoice_footer"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "student_lists", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_student_lists_on_list_id", using: :btree
    t.index ["student_id"], name: "index_student_lists_on_student_id", using: :btree
  end

  create_table "students", force: :cascade do |t|
    t.string   "full_name"
    t.string   "full_name_english"
    t.string   "nickname"
    t.string   "nickname_english"
    t.integer  "gender_id"
    t.datetime "birthdate"
    t.integer  "grade_id"
    t.string   "classroom"
    t.integer  "classroom_number"
    t.integer  "student_number"
    t.string   "national_id"
    t.text     "remark"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "school_id"
    t.datetime "deleted_at"
    t.string   "status"
    t.string   "img_url_file_name"
    t.string   "img_url_content_type"
    t.integer  "img_url_file_size"
    t.datetime "img_url_updated_at"
    t.index ["deleted_at"], name: "index_students_on_deleted_at", using: :btree
    t.index ["school_id"], name: "index_students_on_school_id", using: :btree
  end

  create_table "students_parents", force: :cascade do |t|
    t.integer  "student_id",      null: false
    t.integer  "parent_id",       null: false
    t.integer  "relationship_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "tax_reductions", force: :cascade do |t|
    t.integer "employee_id"
    t.decimal "pension_insurance",        default: "0.0",     null: false
    t.decimal "pension_fund",             default: "0.0",     null: false
    t.decimal "government_pension_fund",  default: "0.0",     null: false
    t.decimal "private_teacher_aid_fund", default: "0.0",     null: false
    t.decimal "retirement_mutual_fund",   default: "0.0",     null: false
    t.decimal "national_savings_fund",    default: "0.0",     null: false
    t.decimal "expenses",                 default: "60000.0", null: false
    t.decimal "no_income_spouse",         default: "0.0",     null: false
    t.decimal "child",                    default: "0.0",     null: false
    t.decimal "father_alimony",           default: "0.0",     null: false
    t.decimal "spouse_father_alimony",    default: "0.0",     null: false
    t.decimal "cripple_alimony",          default: "0.0",     null: false
    t.decimal "father_insurance",         default: "0.0",     null: false
    t.decimal "insurance",                default: "0.0",     null: false
    t.decimal "spouse_insurance",         default: "0.0",     null: false
    t.decimal "long_term_equity_fund",    default: "0.0",     null: false
    t.decimal "social_insurance",         default: "0.0",     null: false
    t.decimal "double_donation",          default: "0.0",     null: false
    t.decimal "donation",                 default: "0.0",     null: false
    t.decimal "other",                    default: "0.0",     null: false
    t.decimal "mother_alimony",           default: "0.0",     null: false
    t.decimal "spouse_mother_alimony",    default: "0.0",     null: false
    t.decimal "mother_insurance",         default: "0.0",     null: false
    t.decimal "spouse_father_insurance",  default: "0.0",     null: false
    t.decimal "spouse_mother_insurance",  default: "0.0",     null: false
    t.decimal "house_loan_interest",      default: "0.0",     null: false
    t.index ["employee_id"], name: "index_tax_reductions_on_employee_id", using: :btree
  end

  create_table "taxrates", force: :cascade do |t|
    t.integer "order_id"
    t.float   "income"
    t.float   "tax"
  end

  create_table "teacher_attendance_lists", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "list_id"
    t.index ["employee_id"], name: "index_teacher_attendance_lists_on_employee_id", using: :btree
    t.index ["list_id"], name: "index_teacher_attendance_lists_on_list_id", using: :btree
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
    t.string   "full_name"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["school_id"], name: "index_users_on_school_id", using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

  add_foreign_key "class_permisions", "lists"
  add_foreign_key "class_permisions", "users"
  add_foreign_key "individuals", "employees", column: "child_id"
  add_foreign_key "individuals", "employees", column: "emergency_call_id"
  add_foreign_key "individuals", "employees", column: "friend_id"
  add_foreign_key "individuals", "employees", column: "parent_id"
  add_foreign_key "individuals", "employees", column: "spouse_id"
  add_foreign_key "roll_calls", "lists"
  add_foreign_key "students", "schools"
  add_foreign_key "users", "schools"
end
