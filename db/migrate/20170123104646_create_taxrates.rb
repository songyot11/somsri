class CreateTaxrates < ActiveRecord::Migration[5.0]
  def change
    create_table :taxrates do |t|
      t.integer :order
      t.float :income
      t.float :tax
    end
  end
end
