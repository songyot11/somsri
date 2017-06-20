class AddNoteToPayroll < ActiveRecord::Migration[5.0]
  def change
    add_column :payrolls, :note, :text
  end
end
