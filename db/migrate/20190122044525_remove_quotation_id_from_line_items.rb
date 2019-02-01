class RemoveQuotationIdFromLineItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :line_items, :quotation_id, :integer
  end
end
