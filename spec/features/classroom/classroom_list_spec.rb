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

  let(:teacher) do
    Employee.make!({
      school_id: school.id,
      first_name: "คนใหม่",
      last_name: "เดือนแรกเลย",
      prefix_thai: "นาย",
      classroom: classrooms[0],
      salary: 20000
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
    teacher
  end

  it 'should access to classroom page' do
    visit '/main#/classroom'
    sleep(1)
    eventually { expect(page).to have_content("1A 1 2") }
    eventually { expect(page).to have_content("1B 0 0") }
    eventually { expect(page).to have_content("2A 0 1") }
    eventually { expect(page).to have_content("2B 0 0") }
  end

  it 'should create classroom' do
    visit '/main#/classroom'
    sleep(1)
    click_button('สร้างห้องเรียน')
    sleep(1)
    find('#grade-select').click
    find("a", text: "Kindergarten 2").click
    find('input#classroom').set("Mind Room")
    click_button('บันทึก')
    sleep(1)
    eventually { expect(page).to have_content("Kindergarten 2 Mind Room 0 0") }
  end

  it 'should not create dupplicate classroom' do
    visit '/main#/classroom'
    sleep(1)
    click_button('สร้างห้องเรียน')
    sleep(1)
    find('#grade-select').click
    find("a", text: "Kindergarten 2").click
    find('input#classroom').set("2A")
    click_button('บันทึก')
    sleep(1)
    eventually { expect(page).to have_content("*มีห้องเรียนนี้ในระบบแล้ว") }
  end

  it 'should not create dupplicate classroom with case insensitive' do
    visit '/main#/classroom'
    sleep(1)
    click_button('สร้างห้องเรียน')
    sleep(1)
    find('#grade-select').click
    find("a", text: "Kindergarten 2").click
    find('input#classroom').set("2a")
    click_button('บันทึก')
    sleep(1)
    eventually { expect(page).to have_content("*มีห้องเรียนนี้ในระบบแล้ว") }
  end

  it 'should filter by grade id' do
    visit '/main#/classroom'
    sleep(1)
    find("#grade-list").click
    find("a", text: grades[0].name).click
    eventually { expect(page).to have_content("1A 1 2") }
    eventually { expect(page).to have_content("1B 0 0") }
  end

  it 'should delete classroom' do
    visit '/main#/classroom'
    sleep(1)
    onclick = 'onclick="angular.element(document.getElementById(\'angularCtrl\')).scope().classroom.removeClassroom(' + classrooms[0].id.to_s + ')"'
    find("a[" + onclick + "]").click
    sleep(1)
    click_button("ตกลง")

    eventually { expect(page).to_not have_content("1A 1 2") }
    eventually { expect(page).to have_content("1B 0 0") }
    eventually { expect(page).to have_content("2A 0 1") }
    eventually { expect(page).to have_content("2B 0 0") }

    teacher.reload
    students[0].reload
    students[1].reload

    eventually { expect(teacher.classroom_id).to eq nil }
    eventually { expect(students[0].classroom_id).to eq nil }
    eventually { expect(students[1].classroom_id).to eq nil }
  end
end
