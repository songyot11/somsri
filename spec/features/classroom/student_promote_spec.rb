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
    [
      Classroom.make!({id: 1, name: "1A", grade_id: grades[0].id, next_id: 3}),
      Classroom.make!({id: 2,name: "1B", grade_id: grades[0].id, next_id: 4}),
      Classroom.make!({id: 3, name: "2A", grade_id: grades[1].id, next_id: 5}),
      Classroom.make!({id: 4, name: "2B", grade_id: grades[1].id}),
      Classroom.make!({id: 5, name: "3A", grade_id: grades[2].id})
    ]
  end

  let(:classrooms_no_next_id) do
    [
      Classroom.make!({ name: "1A", grade_id: grades[0].id}),
      Classroom.make!({ name: "1B", grade_id: grades[0].id}),
      Classroom.make!({ name: "2A", grade_id: grades[1].id})
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

  let(:students_no_next_id) do
    [
      Student.make!({
        first_name: 'สมศรี1',
        last_name: 'ใบเสร็จ',
        grade_id: grades[0].id,
        classroom: classrooms_no_next_id[0],
        classroom_number: 106,
        student_number: 9006,
        birthdate: Time.now
      }),
      Student.make!({
        first_name: 'สมศรี2',
        last_name: 'ใบเสร็จ',
        grade_id: grades[0].id,
        classroom: classrooms_no_next_id[0],
        classroom_number: 106,
        student_number: 9006,
        birthdate: Time.now
      }),
      Student.make!({
        first_name: 'สมศรี3',
        last_name: 'ใบเสร็จ',
        classroom: classrooms_no_next_id[2],
        grade_id: grades[1].id,
        classroom_number: 106,
        student_number: 9006,
        birthdate: Time.now
      })
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

    it 'should promote students' do
      click_button("เลื่อนชั้นเรียน")
      sleep(1)
      click_button("ตกลง")
      eventually { expect(page).to have_content("1A 0 0") }
      eventually { expect(page).to have_content("1B 0 0") }
      eventually { expect(page).to have_content("2A 0 1") }
      eventually { expect(page).to have_content("2B 0 2") }
      eventually { expect(page).to have_content("3A 0 3") }
    end
  end

  describe 'Classroom without next_id' do
    before do
      school
      user.add_role :admin
      login_as(user, scope: :user)
      students_no_next_id
      visit '/main#/classroom'
    end

    it 'should display disable promote button' do
      eventually { expect(page).to have_content("1A 0 2") }
      eventually { expect(page).to have_content("1B 0 0") }
      eventually { expect(page).to have_content("2A 0 1") }
      eventually { expect(page).to have_button('เลื่อนชั้นเรียน', disabled: true) }
    end
  end
end
