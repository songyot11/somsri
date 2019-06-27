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

ActiveRecord::Schema.define(version: 20190626020645) do

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

  create_table "alumnis", force: :cascade do |t|
    t.integer  "student_id"
    t.string   "name"
    t.string   "nickname"
    t.integer  "student_number"
    t.string   "graduated_year"
    t.string   "graduated_semester"
    t.string   "grade"
    t.string   "classroom"
    t.string   "status"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["student_id"], name: "index_alumnis_on_student_id", using: :btree
  end

  create_table "banks", force: :cascade do |t|
    t.string   "bank_name"
    t.string   "bank_account"
    t.string   "account_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "bank_id"
  end

  create_table "candidate_files", force: :cascade do |t|
    t.string   "files_file_name"
    t.string   "files_content_type"
    t.integer  "files_file_size"
    t.datetime "files_updated_at"
    t.integer  "candidate_id"
    t.index ["candidate_id"], name: "index_candidate_files_on_candidate_id", using: :btree
  end

  create_table "candidates", force: :cascade do |t|
    t.string   "full_name"
    t.string   "nick_name"
    t.string   "email"
    t.string   "phone"
    t.string   "from"
    t.string   "school_year"
    t.string   "note"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "current_ability"
    t.integer  "learn_ability"
    t.integer  "attention"
    t.datetime "deleted_at"
    t.boolean  "shortlist",          default: false
    t.string   "interest"
    t.index ["deleted_at"], name: "index_candidates_on_deleted_at", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.integer  "inventory_id"
    t.string   "category_id"
    t.string   "category_name"
    t.string   "category_barcode"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["inventory_id"], name: "index_categories_on_inventory_id", using: :btree
  end

  create_table "class_permisions", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "list_id"
    t.integer  "employee_id"
    t.index ["employee_id"], name: "index_class_permisions_on_employee_id", using: :btree
    t.index ["list_id"], name: "index_class_permisions_on_list_id", using: :btree
  end

  create_table "classrooms", force: :cascade do |t|
    t.integer  "next_id"
    t.integer  "grade_id"
    t.string   "name",       default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["grade_id"], name: "index_classrooms_on_grade_id", using: :btree
    t.index ["next_id"], name: "index_classrooms_on_next_id", using: :btree
  end

  create_table "comfy_cms_blocks", force: :cascade do |t|
    t.string   "identifier",     null: false
    t.text     "content"
    t.string   "blockable_type"
    t.integer  "blockable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["blockable_id", "blockable_type"], name: "index_comfy_cms_blocks_on_blockable_id_and_blockable_type", using: :btree
    t.index ["identifier"], name: "index_comfy_cms_blocks_on_identifier", using: :btree
  end

  create_table "comfy_cms_categories", force: :cascade do |t|
    t.integer "site_id",          null: false
    t.string  "label",            null: false
    t.string  "categorized_type", null: false
    t.index ["site_id", "categorized_type", "label"], name: "index_cms_categories_on_site_id_and_cat_type_and_label", unique: true, using: :btree
  end

  create_table "comfy_cms_categorizations", force: :cascade do |t|
    t.integer "category_id",      null: false
    t.string  "categorized_type", null: false
    t.integer "categorized_id",   null: false
    t.index ["category_id", "categorized_type", "categorized_id"], name: "index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id", unique: true, using: :btree
  end

  create_table "comfy_cms_files", force: :cascade do |t|
    t.integer  "site_id",                                    null: false
    t.integer  "block_id"
    t.string   "label",                                      null: false
    t.string   "file_file_name",                             null: false
    t.string   "file_content_type",                          null: false
    t.integer  "file_file_size",                             null: false
    t.string   "description",       limit: 2048
    t.integer  "position",                       default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["site_id", "block_id"], name: "index_comfy_cms_files_on_site_id_and_block_id", using: :btree
    t.index ["site_id", "file_file_name"], name: "index_comfy_cms_files_on_site_id_and_file_file_name", using: :btree
    t.index ["site_id", "label"], name: "index_comfy_cms_files_on_site_id_and_label", using: :btree
    t.index ["site_id", "position"], name: "index_comfy_cms_files_on_site_id_and_position", using: :btree
  end

  create_table "comfy_cms_layouts", force: :cascade do |t|
    t.integer  "site_id",                    null: false
    t.integer  "parent_id"
    t.string   "app_layout"
    t.string   "label",                      null: false
    t.string   "identifier",                 null: false
    t.text     "content"
    t.text     "css"
    t.text     "js"
    t.integer  "position",   default: 0,     null: false
    t.boolean  "is_shared",  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["parent_id", "position"], name: "index_comfy_cms_layouts_on_parent_id_and_position", using: :btree
    t.index ["site_id", "identifier"], name: "index_comfy_cms_layouts_on_site_id_and_identifier", unique: true, using: :btree
  end

  create_table "comfy_cms_pages", force: :cascade do |t|
    t.integer  "site_id",                        null: false
    t.integer  "layout_id"
    t.integer  "parent_id"
    t.integer  "target_page_id"
    t.string   "label",                          null: false
    t.string   "slug"
    t.string   "full_path",                      null: false
    t.text     "content_cache"
    t.integer  "position",       default: 0,     null: false
    t.integer  "children_count", default: 0,     null: false
    t.boolean  "is_published",   default: true,  null: false
    t.boolean  "is_shared",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["parent_id", "position"], name: "index_comfy_cms_pages_on_parent_id_and_position", using: :btree
    t.index ["site_id", "full_path"], name: "index_comfy_cms_pages_on_site_id_and_full_path", using: :btree
  end

  create_table "comfy_cms_revisions", force: :cascade do |t|
    t.string   "record_type", null: false
    t.integer  "record_id",   null: false
    t.text     "data"
    t.datetime "created_at"
    t.index ["record_type", "record_id", "created_at"], name: "index_cms_revisions_on_rtype_and_rid_and_created_at", using: :btree
  end

  create_table "comfy_cms_sites", force: :cascade do |t|
    t.string  "label",                       null: false
    t.string  "identifier",                  null: false
    t.string  "hostname",                    null: false
    t.string  "path"
    t.string  "locale",      default: "en",  null: false
    t.boolean "is_mirrored", default: false, null: false
    t.index ["hostname"], name: "index_comfy_cms_sites_on_hostname", using: :btree
    t.index ["is_mirrored"], name: "index_comfy_cms_sites_on_is_mirrored", using: :btree
  end

  create_table "comfy_cms_snippets", force: :cascade do |t|
    t.integer  "site_id",                    null: false
    t.string   "label",                      null: false
    t.string   "identifier",                 null: false
    t.text     "content"
    t.integer  "position",   default: 0,     null: false
    t.boolean  "is_shared",  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["site_id", "identifier"], name: "index_comfy_cms_snippets_on_site_id_and_identifier", unique: true, using: :btree
    t.index ["site_id", "position"], name: "index_comfy_cms_snippets_on_site_id_and_position", using: :btree
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

  create_table "design_skills", force: :cascade do |t|
    t.string  "skill_name"
    t.integer "skill_point"
    t.integer "candidate_id"
    t.index ["candidate_id"], name: "index_design_skills_on_candidate_id", using: :btree
  end

  create_table "employee_skills", force: :cascade do |t|
    t.integer  "employee_id"
    t.integer  "skill_id"
    t.integer  "score"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["employee_id"], name: "index_employee_skills_on_employee_id", using: :btree
    t.index ["skill_id"], name: "index_employee_skills_on_skill_id", using: :btree
  end

  create_table "employees", force: :cascade do |t|
    t.integer  "school_id"
    t.string   "first_name",                           default: "",             null: false
    t.string   "last_name",                            default: "",             null: false
    t.string   "middle_name",                          default: "",             null: false
    t.string   "prefix",                               default: "",             null: false
    t.integer  "sex",                                  default: 0,              null: false
    t.string   "position",                             default: ""
    t.string   "personal_id",                          default: ""
    t.string   "passport_number",                      default: ""
    t.string   "race",                                 default: ""
    t.string   "nationality",                          default: ""
    t.string   "bank_name",                            default: ""
    t.string   "bank_branch",                          default: ""
    t.string   "account_number",                       default: ""
    t.decimal  "salary",                               default: "0.0",          null: false
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
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
    t.string   "employee_type",                        default: "ลูกจ้างประจำ", null: false
    t.boolean  "pay_social_insurance"
    t.boolean  "pay_pvf"
    t.string   "pin"
    t.integer  "grade_id"
    t.string   "classroom_name"
    t.string   "img_url_file_name"
    t.string   "img_url_content_type"
    t.integer  "img_url_file_size"
    t.datetime "img_url_updated_at"
    t.datetime "deleted_at"
    t.integer  "classroom_id"
    t.string   "encrypted_password",                   default: "",             null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        default: 0,              null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "leave_allowance",                      default: 0
    t.string   "note"
    t.string   "comment"
    t.string   "name"
    t.string   "full_name"
    t.integer  "sick_leave_maximum_days_per_year"
    t.integer  "personal_leave_maximum_days_per_year"
    t.integer  "switching_day_maximum_days_per_year"
    t.integer  "work_at_home_maximum_days_per_week"
    t.boolean  "switching_day_allow"
    t.boolean  "work_at_home_allow"
    t.index ["classroom_id"], name: "index_employees_on_classroom_id", using: :btree
    t.index ["deleted_at"], name: "index_employees_on_deleted_at", using: :btree
    t.index ["email"], name: "index_employees_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_employees_on_reset_password_token", unique: true, using: :btree
    t.index ["school_id"], name: "index_employees_on_school_id", using: :btree
  end

  create_table "employees_roles", id: false, force: :cascade do |t|
    t.integer "employee_id"
    t.integer "role_id"
    t.index ["employee_id", "role_id"], name: "index_employees_roles_on_employee_id_and_role_id", using: :btree
    t.index ["employee_id"], name: "index_employees_roles_on_employee_id", using: :btree
    t.index ["role_id"], name: "index_employees_roles_on_role_id", using: :btree
  end

  create_table "expense_items", force: :cascade do |t|
    t.integer "expense_id"
    t.string  "detail"
    t.integer "amount"
    t.float   "cost"
    t.index ["expense_id"], name: "index_expense_items_on_expense_id", using: :btree
  end

  create_table "expense_tag_items", force: :cascade do |t|
    t.integer "expense_tag_id"
    t.integer "expense_item_id"
    t.index ["expense_item_id"], name: "index_expense_tag_items_on_expense_item_id", using: :btree
    t.index ["expense_tag_id"], name: "index_expense_tag_items_on_expense_tag_id", using: :btree
  end

  create_table "expense_tags", force: :cascade do |t|
    t.string "name"
    t.string "description"
  end

  create_table "expenses", force: :cascade do |t|
    t.datetime "effective_date"
    t.string   "expenses_id"
    t.string   "detail"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "deleted_at"
    t.string   "img_url_file_name"
    t.string   "img_url_content_type"
    t.integer  "img_url_file_size"
    t.datetime "img_url_updated_at"
    t.float    "total_cost"
    t.string   "payment_method"
    t.string   "cheque_bank_name"
    t.string   "cheque_number"
    t.string   "cheque_date"
    t.string   "transfer_bank_name"
    t.string   "transfer_date"
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

  create_table "grouping_report_options", force: :cascade do |t|
    t.string "name"
    t.string "keyword"
  end

  create_table "holidays", force: :cascade do |t|
    t.string   "name"
    t.string   "name_en"
    t.datetime "start_at"
    t.datetime "end_at"
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

  create_table "inventories", force: :cascade do |t|
    t.string   "item_name"
    t.string   "serial_number"
    t.string   "model"
    t.string   "description"
    t.float    "price"
    t.datetime "date_purchase"
    t.datetime "date_add"
    t.datetime "end_warranty"
    t.integer  "employee_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "supplier_id"
    t.index ["supplier_id"], name: "index_inventories_on_supplier_id", using: :btree
  end

  create_table "inventory_repairs", force: :cascade do |t|
    t.integer  "inventory_id"
    t.integer  "inventory_request_id"
    t.integer  "employee_id"
    t.string   "employee_name"
    t.string   "item_name"
    t.string   "serial_number"
    t.string   "reason"
    t.datetime "repair_date"
    t.datetime "return_date"
    t.float    "price"
    t.string   "receipt"
    t.integer  "repair_status"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["employee_id"], name: "index_inventory_repairs_on_employee_id", using: :btree
    t.index ["inventory_id"], name: "index_inventory_repairs_on_inventory_id", using: :btree
    t.index ["inventory_request_id"], name: "index_inventory_repairs_on_inventory_request_id", using: :btree
  end

  create_table "inventory_requests", force: :cascade do |t|
    t.string   "user_name"
    t.string   "item_name"
    t.string   "description"
    t.float    "price"
    t.datetime "request_date"
    t.integer  "inventory_status"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "comment"
    t.integer  "employee_id"
    t.integer  "inventory_id"
    t.datetime "return_date"
    t.integer  "request_count"
    t.string   "request_type"
    t.datetime "define_return_date"
    t.index ["employee_id"], name: "index_inventory_requests_on_employee_id", using: :btree
    t.index ["inventory_id"], name: "index_inventory_requests_on_inventory_id", using: :btree
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
    t.string   "classroom"
    t.string   "student_name"
    t.string   "parent_name"
    t.string   "user_name"
  end

  create_table "line_item_quotations", force: :cascade do |t|
    t.string   "detail"
    t.float    "amount"
    t.integer  "quotation_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
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

  create_table "lt_banks", force: :cascade do |t|
    t.string "name"
    t.string "image_path"
  end

  create_table "manage_inventory_repairs", force: :cascade do |t|
    t.integer  "inventory_repair_id"
    t.integer  "step"
    t.string   "step1_save_by"
    t.datetime "repair_date"
    t.string   "supplier_name"
    t.datetime "appointment_date"
    t.string   "step2_save_by"
    t.datetime "return_date"
    t.float    "price"
    t.string   "receipt"
    t.string   "step3_save_by"
    t.integer  "employee_id"
    t.string   "step4_save_by"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["inventory_repair_id"], name: "index_manage_inventory_repairs_on_inventory_repair_id", using: :btree
  end

  create_table "manage_inventory_requests", force: :cascade do |t|
    t.integer  "inventory_request_id"
    t.integer  "step"
    t.string   "save_by"
    t.string   "accept"
    t.string   "save_by_step2"
    t.datetime "date_purchase"
    t.datetime "date_send"
    t.string   "price"
    t.string   "save_by_step3"
    t.datetime "get_date"
    t.string   "buy_slip"
    t.datetime "end_warranty"
    t.string   "save_by_step4"
    t.string   "send_to_employee_name"
    t.string   "send_to_employee_id"
    t.string   "save_by_step5"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "inventory_id"
    t.index ["inventory_request_id"], name: "index_manage_inventory_requests_on_inventory_request_id", using: :btree
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
    t.datetime "effective_date"
    t.datetime "deleted_at"
    t.text     "note"
    t.boolean  "closed"
    t.index ["deleted_at"], name: "index_payrolls_on_deleted_at", using: :btree
    t.index ["employee_id"], name: "index_payrolls_on_employee_id", using: :btree
  end

  create_table "programming_skills", force: :cascade do |t|
    t.string  "skill_name"
    t.integer "skill_point"
    t.integer "candidate_id"
    t.index ["candidate_id"], name: "index_programming_skills_on_candidate_id", using: :btree
  end

  create_table "quotation_invoices", force: :cascade do |t|
    t.integer "quotation_id"
    t.integer "invoice_id"
  end

  create_table "quotations", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.integer  "quotation_status"
    t.text     "remark"
    t.string   "school_year"
    t.string   "semester"
    t.string   "grade_name"
    t.string   "student_name"
    t.string   "parent_name"
    t.string   "user_name"
    t.date     "payment_date_start"
    t.date     "payment_date_end"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
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

  create_table "school_settings", force: :cascade do |t|
    t.string "school_year",      default: ""
    t.string "semesters"
    t.string "current_semester"
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
    t.text     "payroll_slip_header"
  end

  create_table "site_configs", force: :cascade do |t|
    t.boolean "enable_rollcall",                      default: true
    t.boolean "default_cash_payment_method",          default: true
    t.boolean "default_credit_card_payment_method",   default: false
    t.boolean "default_cheque_payment_method",        default: false
    t.boolean "default_transfer_payment_method",      default: false
    t.boolean "display_username_password_on_login",   default: false
    t.boolean "display_schools_year_with_invoice_id", default: true
    t.boolean "web_cms",                              default: false
    t.boolean "tax",                                  default: true
    t.integer "student_number_leading_zero",          default: 0
    t.boolean "one_slip_per_page",                    default: false
    t.boolean "export_ktb_payroll",                   default: false
    t.boolean "outstanding_notification",             default: false
    t.boolean "slip_carbon",                          default: false
    t.string  "default_locale",                       default: "th"
    t.boolean "enable_expenses",                      default: false
    t.string  "expense_tag_tree"
    t.boolean "enable_quotation",                     default: false
    t.boolean "export_kbank_payroll",                 default: false
    t.string  "bank_account"
  end

  create_table "skills", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "soft_skills", force: :cascade do |t|
    t.string  "skill_name"
    t.integer "skill_point"
    t.integer "candidate_id"
    t.index ["candidate_id"], name: "index_soft_skills_on_candidate_id", using: :btree
  end

  create_table "student_lists", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_student_lists_on_deleted_at", using: :btree
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
    t.string   "classroom_name"
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
    t.integer  "classroom_id"
    t.string   "nationality"
    t.index ["classroom_id"], name: "index_students_on_classroom_id", using: :btree
    t.index ["deleted_at"], name: "index_students_on_deleted_at", using: :btree
    t.index ["school_id"], name: "index_students_on_school_id", using: :btree
  end

  create_table "students_parents", force: :cascade do |t|
    t.integer  "student_id",      null: false
    t.integer  "parent_id",       null: false
    t.integer  "relationship_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_students_parents_on_deleted_at", using: :btree
  end

  create_table "suppliers", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "phone_number"
    t.string   "email"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
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

  create_table "vacation_configs", force: :cascade do |t|
    t.integer "vacation_leave_advance_at_least", default: 0
    t.integer "switch_date_advance_at_least",    default: 0
    t.integer "work_at_home_unit",               default: 0
    t.integer "work_at_home_limit",              default: 0
    t.boolean "can_leave_half_day",              default: true
  end

  create_table "vacation_leave_rules", force: :cascade do |t|
    t.text     "message"
    t.integer  "updated_by_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["updated_by_id"], name: "index_vacation_leave_rules_on_updated_by_id", using: :btree
  end

  create_table "vacation_settings", force: :cascade do |t|
    t.integer "school_id"
    t.integer "sick_leave_maximum_days_per_year",       default: 30
    t.boolean "sick_leave_require_approval"
    t.boolean "sick_leave_require_medical_certificate"
    t.string  "sick_leave_note"
    t.integer "personal_leave_maximum_days_per_year",   default: 15
    t.integer "personal_leave_submission_days",         default: 2
    t.boolean "personal_leave_allow_morning",           default: true
    t.boolean "personal_leave_allow_afternoon",         default: true
    t.string  "personal_leave_note"
    t.boolean "switching_day_allow",                    default: true
    t.integer "switching_day_maximum_days_per_year",    default: 15
    t.boolean "switching_day_require_approval",         default: true
    t.integer "switching_day_submission_days",          default: 2
    t.string  "switching_day_note"
    t.boolean "work_at_home_allow",                     default: true
    t.integer "work_at_home_maximum_days_per_week",     default: 2
    t.boolean "work_at_home_require_approval"
    t.integer "work_at_home_submission_days"
    t.string  "work_at_home_note"
    t.index ["school_id"], name: "index_vacation_settings_on_school_id", using: :btree
  end

  create_table "vacation_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.float    "deduce_days"
  end

  create_table "vacations", force: :cascade do |t|
    t.integer  "approver_id"
    t.integer  "vacation_type_id"
    t.integer  "status",           default: 0
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "detail"
    t.string   "start_date"
    t.string   "end_date"
    t.integer  "requester_id"
    t.index ["approver_id"], name: "index_vacations_on_approver_id", using: :btree
    t.index ["vacation_type_id"], name: "index_vacations_on_vacation_type_id", using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.bigint   "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "candidate_files", "candidates"
  add_foreign_key "class_permisions", "employees"
  add_foreign_key "class_permisions", "lists"
  add_foreign_key "classrooms", "classrooms", column: "next_id", on_delete: :nullify
  add_foreign_key "design_skills", "candidates"
  add_foreign_key "employee_skills", "employees"
  add_foreign_key "employee_skills", "skills"
  add_foreign_key "employees", "classrooms", on_delete: :nullify
  add_foreign_key "individuals", "employees", column: "child_id"
  add_foreign_key "individuals", "employees", column: "emergency_call_id"
  add_foreign_key "individuals", "employees", column: "friend_id"
  add_foreign_key "individuals", "employees", column: "parent_id"
  add_foreign_key "individuals", "employees", column: "spouse_id"
  add_foreign_key "programming_skills", "candidates"
  add_foreign_key "roll_calls", "lists"
  add_foreign_key "soft_skills", "candidates"
  add_foreign_key "students", "classrooms", on_delete: :nullify
  add_foreign_key "students", "schools"
  add_foreign_key "users", "schools"
end
