class ChangeImageType < ActiveRecord::Migration[5.0]
  def change
    remove_attachment :lt_banks, :image
    add_column :lt_banks, :image_path, :string
  end
end
