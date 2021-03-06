json.current_page @invoices.current_page
json.total_records @invoices.total_entries
json.datas do |invoicesElement|
  invoicesElement.array!(@invoices) do |invoice|
    json.extract! invoice, :id, :student_id, :parent_id, :user_id, :remark, :payment_method_id, :cheque_bank_name, :cheque_number, :cheque_date, :transfer_bank_name, :transfer_date, :invoice_status_id, :school_year, :semester, :created_at, :updated_at, :student_full_name_with_nickname, :grade_name, :parent_name, :payee_name, :payment_method_names, :status_name, :total_amount, :is_cancel
  end
end
json.url invoice_url(invoice, format: :json)
