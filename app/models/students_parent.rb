class StudentsParent < ApplicationRecord
  belongs_to :student
  belongs_to :parent
  belongs_to :relationship

  acts_as_paranoid

  def self.newRelationship(student_id, parent_id, relation_name)
    std_parent = StudentsParent.new()
    std_parent.student_id = student_id
    std_parent.parent_id = parent_id
    std_parent.relationship_id = Relationship.find_by_name(relation_name).id
    return std_parent
  end

end
