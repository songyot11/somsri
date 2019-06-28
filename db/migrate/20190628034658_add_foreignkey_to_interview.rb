class AddForeignkeyToInterview < ActiveRecord::Migration[5.0]
  def change
    add_reference :interviews, :candidate, foreign_key: {to_table: :candidates}
  end
end
