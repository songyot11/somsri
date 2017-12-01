class AddInvoiceDetail < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :classroom, :string
    add_column :invoices, :student_name, :string
    add_column :invoices, :parent_name, :string
    add_column :invoices, :user_name, :string

    Invoice.all.each do |invoice|
      if invoice.student
        invoice.student_name = invoice.student.invoice_screen_full_name_display
        invoice.classroom = invoice.student.classroom.name
      end

      if invoice.parent
        invoice.parent_name = invoice.parent.full_name
      end

      if invoice.user
        invoice.user_name = invoice.user.name
      end
      invoice.save
    end
  end
end
