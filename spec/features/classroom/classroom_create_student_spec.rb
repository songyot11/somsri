describe 'Classroom Create Teacher', js: true do

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
      }),
      Student.make!({
        first_name: 'สมศรี4',
        last_name: 'ใบเสร็จ',
        student_number: 9006,
        birthdate: Time.now
      }),
      Student.make!({
        first_name: 'สมศรี5',
        last_name: 'ใบเสร็จ',
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
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_link("นักเรียน")
    sleep(1)
    click_button("+ เลือกนักเรียน")
    eventually { expect(page).to have_content("สมศรี4 ใบเสร็จ") }
    eventually { expect(page).to have_content("สมศรี5 ใบเสร็จ") }
    click_button("+ สร้าง นักเรียน")
    eventually { expect(page).to have_content("สร้าง นักเรียน") }
  end

  it 'should create teacher' do
    within('div#create-member-modal') do
      eventually { expect(page).to have_content("สร้าง นักเรียน") }
      fill_in "ชื่อ - นามสกุล",  with: "สมเสร็จ ใบศรี"
      fill_in "ชื่อเล่น",  with: "สม"
      click_button('บันทึก')
    end
    eventually { expect(page).to have_content("สมเสร็จ ใบศรี (สม)") }

    student = Student.where({
      full_name: "สมเสร็จ ใบศร",
      nickname: "สม"
    })
    eventually { expect(student).to_not eq nil }
  end

  it 'should cancel create teacher' do
    within('div#create-member-modal') do
      click_button('ยกเลิก')
    end
    eventually { expect(page).to_not have_content("ชื่อเล่น") }
  end

  it 'should traslate table page student classroom when locale=th' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_link("นักเรียน")
    sleep(1)
    find('button.btn-primary').click
    sleep(1)
    find('input[placeholder="ค้นหา"]').set("หาห้องเรียนไม่เจอหรอก")
    eventually { expect(page).to have_content("ไม่พบรายการที่ค้นหา !") }
  end

  it 'should traslate table page student classroom when locale=en' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    find("#navbarDropdownMenuLink").click
    find('.fa-commenting-o').hover
    find("a", :text => "English").click
    sleep(1)
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_link("Student")
    sleep(1)
    find('button.btn-primary').click
    sleep(1)
    find('input[placeholder="Search"]').set("หาห้องเรียนไม่เจอหรอก")
    eventually { expect(page).to have_content("No matching records found") }
  end
end
