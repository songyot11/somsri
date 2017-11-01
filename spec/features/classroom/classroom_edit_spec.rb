describe 'Classroom Edit', js: true do

  let(:school) do
    School.make!({ name: "โรงเรียนแห่งหนึ่ง" })
  end

  let(:user) { user = User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:grades) do
    [
      Grade.create(name: "Kindergarten 1")
    ]
  end

  let(:classrooms) do
    [
      Classroom.make!({name: "1A", grade_id: grades[0].id})
    ]
  end

  let(:employee) do
    Employee.make!({
      school_id: school.id,
      first_name: "Somsri",
      middle_name: "Is",
      last_name: "Appname",
      prefix: "Mrs.",
      first_name_thai: "สมศรี",
      last_name_thai: "เป็นชื่อแอพ",
      prefix_thai: "นาง",
      sex: 1,
      account_number: "5-234-34532-2342",
      salary: 50000,
      classroom: classrooms[0],
      grade_id: grades[0].id
    })
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
        classroom: classrooms[0],
        grade_id: grades[0].id,
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
    employee
  end

  it 'should access to edit classroom page' do
    visit "/main#/classroom/#{classrooms[0].id}"
    eventually { expect(page).to have_content("นาง สมศรี เป็นชื่อแอพ") }
    eventually { expect(page).to have_content("จำนวน 1 คน") }
  end

  it 'should display all student in classroom' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_link("นักเรียน")
    eventually { expect(page).to have_content("สมศรี3 ใบเสร็จ สมศรี2 ใบเสร็จ สมศรี1 ใบเสร็จ") }
    eventually { expect(page).to have_content("จำนวน 3 คน") }
  end
end
