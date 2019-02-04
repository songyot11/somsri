class RenameOrderToOrderId < ActiveRecord::Migration[5.0]
  def change
    rename_column :taxrates, :order, :order_id
  end
end
