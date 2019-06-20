class CreateCandidate < ActiveRecord::Migration[5.0]
  def change
    create_table :candidates do |t|
      t.string :full_name
      t.string :nick_name
      t.string :email
      t.string :phone
      t.string :from
      t.string :school_year
      t.string :note
      t.timestamps
    end
  end
end
