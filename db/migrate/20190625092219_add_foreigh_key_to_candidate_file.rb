class AddForeighKeyToCandidateFile < ActiveRecord::Migration[5.0]
  def change
    add_reference :candidate_files, :candidate, foreign_key: { to_table: :candidates }
  end
end
