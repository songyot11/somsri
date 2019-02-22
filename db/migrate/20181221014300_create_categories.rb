class CreateCategories < ActiveRecord::Migration[5.0]
  def up
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

  def down
    add_column :inventories, :category, :string
    add_column :inventories, :category_barcode, :string
    drop_table :categories
  end
end
