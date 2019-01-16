class RemoveImageFromBanks < ActiveRecord::Migration[5.0]
  def change
    remove_attachment :banks, :image
  end
end
