class AddQuotationIdToLineItem < ActiveRecord::Migration[5.0]
  def change
    add_column :line_items, :quotation_id, :integer
  end
end
