class CreateParents < ActiveRecord::Migration[5.0]
  def change
    create_table :parents do |t|
      t.string :full_name
      t.string :full_name_english
      t.string :nickname
      t.string :nickname_english
      t.string :mobile
      t.string :email
      t.string :line_id

      t.timestamps
    end
  end
end
