describe 'Student Promote', js: true do

  let(:school) do
    School.make!({ name: "โรงเรียนแห่งหนึ่ง" })
  end

  let(:user) { user = User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:grades) do
    [
      Grade.create(name: "Kindergarten 1"),
      Grade.create(name: "Kindergarten 2"),
      Grade.create(name: "Kindergarten 3")
    ]
  end

  let(:classrooms) do
    Classroom.make!({id: 1, name: "1A", grade_id: grades[0].id})
    Classroom.make!({id: 2, name: "1B", grade_id: grades[0].id})
    Classroom.make!({id: 3, name: "2A", grade_id: grades[1].id})
    Classroom.make!({id: 4, name: "2B", grade_id: grades[1].id})
    Classroom.make!({id: 5, name: "3A", grade_id: grades[2].id})
    Classroom.find(1).update(next_id: 3)
    Classroom.find(2).update(next_id: 4)
    Classroom.find(3).update(next_id: 5)
    [
      Classroom.find(1),
      Classroom.find(2),
      Classroom.find(3),
      Classroom.find(4),
      Classroom.find(5)
    ]
  end

  let(:students) do
    [
      Student.make!({ full_name: 'สมศรี1 ใบเสร็จ', grade_id: grades[0].id, classroom: classrooms[0] }),
      Student.make!({ full_name: 'สมศรี2 ใบเสร็จ', grade_id: grades[0].id, classroom: classrooms[1] }),
      Student.make!({ full_name: 'สมศรี3 ใบเสร็จ', grade_id: grades[0].id, classroom: classrooms[1] }),
      Student.make!({ full_name: 'สมศรี4 ใบเสร็จ', grade_id: grades[1].id, classroom: classrooms[2] }),
      Student.make!({ full_name: 'สมศรี5 ใบเสร็จ', grade_id: grades[1].id, classroom: classrooms[2] }),
      Student.make!({ full_name: 'สมศรี6 ใบเสร็จ', grade_id: grades[1].id, classroom: classrooms[2] }),
      Student.make!({ full_name: 'สมศรี7 ใบเสร็จ', grade_id: grades[1].id, classroom: classrooms[3] }),
      Student.make!({ full_name: 'สมศรี8 ใบเสร็จ', grade_id: grades[1].id, classroom: classrooms[3] }),
      Student.make!({ full_name: 'สมศรี9 ใบเสร็จ', grade_id: grades[1].id, classroom: classrooms[3] }),
      Student.make!({ full_name: 'สมศรี10 ใบเสร็จ', grade_id: grades[1].id, classroom: classrooms[3] }),
      Student.make!({ full_name: 'สมศรี11 ใบเสร็จ', grade_id: grades[2].id, classroom: classrooms[4] }),
      Student.make!({ full_name: 'สมศรี12 ใบเสร็จ', grade_id: grades[2].id, classroom: classrooms[4] }),
      Student.make!({ full_name: 'สมศรี13 ใบเสร็จ', grade_id: grades[2].id, classroom: classrooms[4] }),
      Student.make!({ full_name: 'สมศรี14 ใบเสร็จ', grade_id: grades[2].id, classroom: classrooms[4] }),
      Student.make!({ full_name: 'สมศรี15 ใบเสร็จ', grade_id: grades[2].id, classroom: classrooms[4] })
    ]
  end

  describe 'Classroom with next_id' do
    before do
      school
      user.add_role :admin
      login_as(user, scope: :user)
      students
      visit '/main#/classroom'
    end

    it 'should display clickable promote button' do
      eventually { expect(page).to have_content("1A 0 1") }
      eventually { expect(page).to have_content("1B 0 2") }
      eventually { expect(page).to have_content("2A 0 3") }
      eventually { expect(page).to have_content("2B 0 4") }
      eventually { expect(page).to have_content("3A 0 5") }
      eventually { expect(page).to have_button('เลื่อนชั้นเรียน', disabled: false) }
    end

    it 'should go to next classroom management' do
      click_button("เลื่อนชั้นเรียน")
      sleep(1.5)
      eventually { expect(page).to have_content("ระดับชั้นเรียน เดิม") }
      eventually { expect(page).to have_content("ระดับชั้นเรียนใหม่") }
    end
  end

  describe 'Next classroom' do
    before do
      school
      user.add_role :admin
      login_as(user, scope: :user)
      students
      classrooms
      visit '/main#/next_classroom'
    end

    it 'should promote students and move graduated student to alumni' do
      sleep(1)
      find('button[ng-click="next.studentPromote()"]').click
      sleep(1)
      click_button("ตกลง")
      eventually { expect(page).to have_content("1A 0 0") }
      eventually { expect(page).to have_content("1B 0 0") }
      eventually { expect(page).to have_content("2A 0 1") }
      eventually { expect(page).to have_content("2B 0 2") }
      eventually { expect(page).to have_content("3A 0 3") }

      eventually { expect(Alumni.all.count).to eq 9 }
      eventually { expect(Alumni.where(student_id: students[14].id).exists?).to eq true }
    end

    it 'should change page to classroom list' do
      sleep(1)
      find('button', text: 'ยกเลิก').click
      sleep(1)
      eventually { expect(page).to have_content("1A 0 1") }
      eventually { expect(page).to have_content("1B 0 2") }
      eventually { expect(page).to have_content("2A 0 3") }
      eventually { expect(page).to have_content("2B 0 4") }
      eventually { expect(page).to have_content("3A 0 5") }
    end

    it 'should change next classroom order and promote student' do
      sleep(1)
      find("#classroom-list#{classrooms[0].id}").click
      find('a', text: classrooms[1].grade_with_name).click
      find('button[ng-click="next.studentPromote()"]').click
      click_button("ตกลง")
      sleep(1)
      eventually { expect(page).to have_content("1A 0 0") }
      eventually { expect(page).to have_content("1B 0 1") }
      eventually { expect(page).to have_content("2A 0 0") }
      eventually { expect(page).to have_content("2B 0 2") }
      eventually { expect(page).to have_content("3A 0 3") }

      eventually { expect(Alumni.all.count).to eq 9 }
      eventually { expect(Alumni.where(student_id: students[14].id).exists?).to eq true }
      eventually { expect(Classroom.find(classrooms[0].id).next_id).to eq classrooms[1].id }
    end

    it 'should not promote student when set next classroom to be the same' do
      sleep(1)
      find("#classroom-list#{classrooms[0].id}").click
      find('a', text: classrooms[0].grade_with_name).click
      find("#classroom-list#{classrooms[1].id}").click
      find('a', text: classrooms[1].grade_with_name).click
      find("#classroom-list#{classrooms[2].id}").click
      find('a', text: classrooms[2].grade_with_name).click
      find("#classroom-list#{classrooms[3].id}").click
      find('a', text: classrooms[3].grade_with_name).click
      find("#classroom-list#{classrooms[4].id}").click
      find('a', text: classrooms[4].grade_with_name).click

      find('button[ng-click="next.studentPromote()"]').click
      click_button("ตกลง")
      sleep(1)
      eventually { expect(page).to have_content("1A 0 1") }
      eventually { expect(page).to have_content("1B 0 2") }
      eventually { expect(page).to have_content("2A 0 3") }
      eventually { expect(page).to have_content("2B 0 4") }
      eventually { expect(page).to have_content("3A 0 5") }

      eventually { expect(Alumni.all.count).to eq 0 }
      students.each do |student|
        # student should not change classroom
        eventually { expect(student.classroom_id).to eq Student.find(student.id).classroom_id }
      end

    end
  end
end
