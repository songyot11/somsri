class CreateCategories < ActiveRecord::Migration[5.0]
  def change
  	remove_column :inventories, :category
  	remove_column :inventories, :category_barcode
    create_table :categories do |t|
    	t.belongs_to :inventory
    	t.string :category_id
    	t.string :category_name
    	t.string :category_barcode
      t.timestamps
    end
  end
end
