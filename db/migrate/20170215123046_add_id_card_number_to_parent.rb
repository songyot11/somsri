class AddIdCardNumberToParent < ActiveRecord::Migration[5.0]
  def change
    add_column :parents, :id_card_no, :string
  end
end
