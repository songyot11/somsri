class SchoolLogoPaperClip < ActiveRecord::Migration[5.0]
  def change
    remove_column :schools, :invoice_logo_src
    add_attachment :schools, :logo
  end
end
