describe 'Classroom', js: true do

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
      Grade.create(name: "Kindergarten 2")
    ]
  end

  let(:classrooms) do
    [
      Classroom.make!({name: "1A", grade_id: grades[0].id}),
      Classroom.make!({name: "1B", grade_id: grades[0].id}),
      Classroom.make!({name: "2A", grade_id: grades[1].id}),
      Classroom.make!({name: "2B", grade_id: grades[1].id})
    ]
  end

  let(:students) do
    [
      Student.make!({
        first_name: 'สมศรี1',
        last_name: 'ใบเสร็จ',
        grade_id: grades[0].id,
        classroom: classrooms[0],
        classroom_number: 106,
        student_number: 9006,
        birthdate: Time.now
      }),
      Student.make!({
        first_name: 'สมศรี2',
        last_name: 'ใบเสร็จ',
        grade_id: grades[0].id,
        classroom: classrooms[0],
        classroom_number: 106,
        student_number: 9006,
        birthdate: Time.now
      }),
      Student.make!({
        first_name: 'สมศรี3',
        last_name: 'ใบเสร็จ',
        classroom: classrooms[2],
        grade_id: grades[1].id,
        classroom_number: 106,
        student_number: 9006,
        birthdate: Time.now
      })
    ]
  end

  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    students
  end

  it 'should access to classroom page' do
    visit '/somsri_invoice#/classroom'
    sleep(1)
    eventually { expect(page).to have_content("1A 0 2") }
    eventually { expect(page).to have_content("1B 0 0") }
    eventually { expect(page).to have_content("2A 0 1") }
    eventually { expect(page).to have_content("2B 0 0") }
  end

  it 'should filter by grade id' do
    visit '/somsri_invoice#/classroom'
    sleep(1)
    page.find("#grade-select").select(grades[0].name)
    eventually { expect(page).to have_content("1A 0 2") }
    eventually { expect(page).to have_content("1B 0 0") }
  end
end
