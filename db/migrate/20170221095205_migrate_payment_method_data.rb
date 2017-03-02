class MigratePaymentMethodData < ActiveRecord::Migration[5.0]
  def change
    Invoice.all.each do |invoice|
      payment_method = PaymentMethod.new()
      payment_method.cheque_bank_name = invoice.cheque_bank_name
      payment_method.cheque_number = invoice.cheque_number
      payment_method.cheque_date = invoice.cheque_date
      payment_method.transfer_bank_name = invoice.transfer_bank_name
      payment_method.transfer_date = invoice.transfer_date
      payment_method.invoice_id = invoice.id
      payment_method.payment_method = invoice.payment_method_id
      payment_method.save()
    end
  end
end
