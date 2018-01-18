class SetDefalutNextClassroom < ActiveRecord::Migration[5.0]
  def change
    Classroom.where(next_id: nil).each do |classroom|
      classroom.next_id = classroom.id
      classroom.save
    end
  end
end
