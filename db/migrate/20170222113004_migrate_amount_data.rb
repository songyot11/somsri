class MigrateAmountData < ActiveRecord::Migration[5.0]
  def change
    Invoice.all.each do |invoice|
      total_amount = 0.0
      LineItem.where(invoice_id: invoice.id).to_a.each do |li|
        total_amount += li.amount
      end
      pm = PaymentMethod.where(invoice_id: invoice.id).first
      pm.amount = total_amount
      pm.save()
    end
  end
end
