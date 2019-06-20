class AddImageAndFileToCandidate < ActiveRecord::Migration[5.0]
  def up 
    add_attachment :candidates, :image
    add_attachment :candidates, :file
  end

  def down
    remove_attachment :candidates, :image
    remove_attachment :candidates, :file
  end
end
