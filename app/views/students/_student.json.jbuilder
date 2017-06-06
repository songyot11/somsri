json.current_page @students.current_page
json.total_records @students.total_entries
json.datas do |studentsElement|
  studentsElement.array!(@students) do |student|
    json.extract! student, :id, :full_name, :full_name_english, :nickname, :nickname_english, :gender_id, :birthdate, :grade_id, :classroom, :classroom_number, :student_number, :national_id, :remark, :created_at, :updated_at, :grade_name, :parent_names, :active_invoice_status, :active_invoice_payment_method, :active_invoice_tuition_fee, :active_invoice_other_fee, :active_invoice_total_amount, :active_invoice_updated_at, :grade_name, :full_name_with_title, :nickname_eng_thai, :deleted_at
  end
end
json.url student_url(student, format: :json)
