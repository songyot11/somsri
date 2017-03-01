class CreateClassPermisions < ActiveRecord::Migration[5.0]
  def change
    create_table :class_permisions do |t|

      t.timestamps
    end
  end
end
