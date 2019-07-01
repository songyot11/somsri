class CreateInterview < ActiveRecord::Migration[5.0]
  def change
    create_table :interviews do |t|
      t.string :email
      t.datetime :date
      t.string :location
    end
  end
end
