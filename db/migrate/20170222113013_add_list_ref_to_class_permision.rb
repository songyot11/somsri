class AddListRefToClassPermision < ActiveRecord::Migration[5.0]
  def change
    add_reference :class_permisions, :list, foreign_key: true
  end
end
