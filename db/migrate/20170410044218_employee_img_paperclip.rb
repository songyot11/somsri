class EmployeeImgPaperclip < ActiveRecord::Migration[5.0]
  def change
    remove_column :employees, :img_url

    add_attachment :employees, :img_url
    add_attachment :students, :img_url
    add_attachment :parents, :img_url
  end
end
