class AddAttachmentImgUrlToExpenses < ActiveRecord::Migration
  def self.up
    change_table :expenses do |t|
      t.attachment :img_url
    end
  end

  def self.down
    remove_attachment :expenses, :img_url
  end
end
