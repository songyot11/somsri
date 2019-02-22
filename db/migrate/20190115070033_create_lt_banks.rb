class CreateLtBanks < ActiveRecord::Migration[5.0]
  def change
    create_table :lt_banks do |t|
      t.string :name
      t.attachment :image
    end
  end
end
