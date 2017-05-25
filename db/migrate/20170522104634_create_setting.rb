class CreateSetting < ActiveRecord::Migration[5.0]
  def change
    create_table :school_settings do |t|
      t.string :school_year, default: ""
    end
  end
end
