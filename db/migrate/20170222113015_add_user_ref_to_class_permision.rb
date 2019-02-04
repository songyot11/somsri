class AddUserRefToClassPermision < ActiveRecord::Migration[5.0]
  def change
    add_reference :class_permisions, :user, foreign_key: true
  end
end
