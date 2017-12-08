describe 'Alumni', js: true do

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
        birthdate: Time.now,
        deleted_at: DateTime.now
      }),
      Student.make!({
        first_name: 'สมศรี2',
        last_name: 'ใบเสร็จ',
        grade_id: grades[0].id,
        classroom: classrooms[0],
        classroom_number: 107,
        student_number: 9007,
        birthdate: Time.now,
        deleted_at: DateTime.now
      }),
      Student.make!({
        first_name: 'สมศรี3',
        last_name: 'ใบเสร็จ',
        classroom: classrooms[2],
        grade_id: grades[1].id,
        classroom_number: 108,
        student_number: 9008,
        birthdate: Time.now,
        deleted_at: DateTime.now
      })
    ]
  end

  let(:alumnis) do
    [
      Alumni.make!({
        student_id: students[0].id,
        name: 'สมศรี1 ใบเสร็จ',
        grade: grades[0].name,
        classroom: classrooms[0].name,
        student_number: 9006,
        nickname: "หนึ่ง",
        graduated_year: "2560",
        graduated_semester: "1",
        status: "ลาออก"
      }),
      Alumni.make!({
        student_id: students[1].id,
        name: 'สมศรี2 ใบเสร็จ',
        grade: grades[0].name,
        classroom: classrooms[0].name,
        student_number: 9007,
        nickname: "สอง",
        graduated_year: "2561",
        graduated_semester: "1",
        status: "ลาออก"
      }),
      Alumni.make!({
        student_id: students[2].id,
        name: 'สมศรี3 ใบเสร็จ',
        grade: grades[1].name,
        classroom: classrooms[2].name,
        student_number: 9008,
        nickname: "สาม",
        graduated_year: "2560",
        graduated_semester: "2",
        status: "จบการศึกษา"
      })
    ]
  end

  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    students
    alumnis
  end

  it 'should display to alumni page' do
    visit '/somsri_invoice#/alumni'
    sleep(1)
    eventually { expect(page).to have_content("สมศรี1 ใบเสร็จ หนึ่ง 9006 2560 1 Kindergarten 1 (1A) ลาออก") }
    eventually { expect(page).to have_content("สมศรี2 ใบเสร็จ สอง 9007 2561 1 Kindergarten 1 (1A) ลาออก") }
    eventually { expect(page).to have_content("สมศรี3 ใบเสร็จ สาม 9008 2560 2 Kindergarten 2 (2A) จบการศึกษา") }
  end

  it 'should search rows' do
    visit '/somsri_invoice#/alumni'
    sleep(1)
    page.find('input[placeholder="Search"]').set("สมศรี1")
    eventually { expect(page).to have_content("สมศรี1 ใบเสร็จ หนึ่ง 9006 2560 1 Kindergarten 1 (1A) ลาออก") }
    eventually { expect(page).to_not have_content("สมศรี2 ใบเสร็จ สอง 9007 2561 1 Kindergarten 1 (1A) ลาออก") }
    eventually { expect(page).to_not have_content("สมศรี3 ใบเสร็จ สาม 9008 2560 2 Kindergarten 2 (2A) จบการศึกษา") }
  end

  it 'should filter by year' do
    visit '/somsri_invoice#/alumni'
    sleep(1)
    find('#graduated-year').click
    sleep(1)
    find('a.blue-highlight', :text => '2561').click
    eventually { expect(page).to_not have_content("สมศรี1 ใบเสร็จ หนึ่ง 9006 2560 1 Kindergarten 1 (1A) ลาออก") }
    eventually { expect(page).to have_content("สมศรี2 ใบเสร็จ สอง 9007 2561 1 Kindergarten 1 (1A) ลาออก") }
    eventually { expect(page).to_not have_content("สมศรี3 ใบเสร็จ สาม 9008 2560 2 Kindergarten 2 (2A) จบการศึกษา") }
  end

  it 'should filter by year' do
    visit '/somsri_invoice#/alumni'
    sleep(1)
    find('#graduated-status').click
    sleep(1)
    find('a.blue-highlight', :text => 'ลาออก').click
    eventually { expect(page).to have_content("สมศรี1 ใบเสร็จ หนึ่ง 9006 2560 1 Kindergarten 1 (1A) ลาออก") }
    eventually { expect(page).to have_content("สมศรี2 ใบเสร็จ สอง 9007 2561 1 Kindergarten 1 (1A) ลาออก") }
    eventually { expect(page).to_not have_content("สมศรี3 ใบเสร็จ สาม 9008 2560 2 Kindergarten 2 (2A) จบการศึกษา") }
  end

  it 'should restore student' do
    visit '/somsri_invoice#/alumni'
    sleep(1)
    find('#bringBack' + students[0].id.to_s).click
    eventually { expect(page).to_not have_content("สมศรี1 ใบเสร็จ หนึ่ง 9006 2560 1 Kindergarten 1 (1A) ลาออก") }
    eventually { expect(page).to have_content("สมศรี2 ใบเสร็จ สอง 9007 2561 1 Kindergarten 1 (1A) ลาออก") }
    eventually { expect(page).to have_content("สมศรี3 ใบเสร็จ สาม 9008 2560 2 Kindergarten 2 (2A) จบการศึกษา") }
    eventually { expect(Student.where(id: students[0].id).count).to eq 1 }
    eventually { expect(Alumni.where(student_id: students[0].id).count).to eq 0 }
  end
end
