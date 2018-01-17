describe Parent do

  let(:relationships) do
    [
      Relationship.make!({ name: 'Father' }),
      Relationship.make!({ name: 'Mother' })
    ]
  end

  let(:studentsparent) do
    StudentsParent.make!({student_id: student.id , parent_id: parent.id, relationship_id: relationships[0].id})
  end

  let(:student) do
    Student.make!({
      first_name: 'มั่งมี',
      last_name: 'ศรีสุข',
      nickname: 'รวย' ,
      classroom_number: 13 ,
      student_number: 23 ,
    })
  end

  let(:parent) do
    Parent.make!({full_name: 'Xavi Pepe', mobile: "0999999"})
  end

  let(:parent_no_mobile) do
    Parent.make!({full_name: 'Xavi Pepe', mobile: nil})
  end

  let(:parent_deleted) do
    Parent.make!({full_name: 'แม่โดนลบ แล้วจร้า', mobile: "080-0987654", deleted_at: Time.now})
  end

  describe 'in invoice screen' do
    it 'display full name with tel. (in parentheses)' do
      full_name = parent.invoice_screen_full_name_display
      expect(full_name).to eq('Xavi Pepe (0999999)')
    end

    it 'display full name without parentheses, if there is no tel. number' do
      full_name = parent_no_mobile.invoice_screen_full_name_display
      expect(full_name).to eq('Xavi Pepe')
    end

    it 'should restore parent' do
      expect(Parent.where(id: parent_deleted.id).exists?).to be_falsey
      parent_deleted.restore
      expect(Parent.where(id: parent_deleted.id).exists?).to be_truthy
    end
  end

  it 'should soft delete parent' do
    studentsparent
    expect(Student.where(id: student.id).exists?).to be_truthy
    expect(Parent.where(id: parent.id).exists?).to be_truthy
    expect(StudentsParent.where(id: studentsparent.id).exists?).to be_truthy
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy

    parent.destroy

    # do nothing with student
    expect(Student.where(id: student.id).exists?).to be_truthy

    # soft delete parent
    expect(Parent.where(id: parent.id).exists?).to be_falsey
    expect(Parent.with_deleted.where(id: parent.id).exists?).to be_truthy

    # soft delete parent
    expect(StudentsParent.where(id: studentsparent.id).exists?).to be_falsey
    expect(StudentsParent.with_deleted.where(id: studentsparent.id).exists?).to be_truthy

    # do nothing with student
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy
  end

  it 'should restore deleted parent' do
    studentsparent
    parent.destroy
    expect(Parent.where(id: parent.id).exists?).to be_falsey

    Parent.with_deleted.where(id: parent.id).first.restore_recursively

    expect(Student.where(id: student.id).exists?).to be_truthy
    expect(Parent.where(id: parent.id).exists?).to be_truthy
    expect(StudentsParent.where(id: studentsparent.id).exists?).to be_truthy
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy
  end

end
