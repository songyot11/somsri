class AddFilesToCandidateFile < ActiveRecord::Migration[5.0]
  def up
    add_attachment :candidate_files, :files
  end

  def down
    remove_attachment :candidate_files, :files
  end
end
