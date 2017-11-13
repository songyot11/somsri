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

  let(:employees) do
    [
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
      }),
      Employee.make!({
        school_id: school.id,
        first_name: "Somchit",
        middle_name: "Is",
        last_name: "Boxing",
        prefix: "Mr",
        first_name_thai: "สมจิตร",
        last_name_thai: "เป็นนักมวย",
        prefix_thai: "นาย",
        salary: 20000
      }),
      Employee.make!({
        school_id: school.id,
        first_name: "SomJai",
        middle_name: "Is",
        last_name: "Human",
        prefix: "Mrs.",
        first_name_thai: "สมใจ",
        last_name_thai: "เป็นคน",
        prefix_thai: "นาง",
        salary: 20000
      })
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
    employees
  end

  it 'should access to edit classroom page' do
    visit "/main#/classroom/#{classrooms[0].id}"
    eventually { expect(page).to have_content("นาง สมศรี เป็นชื่อแอพ") }
    # eventually { expect(page).to have_content("จำนวน 1 คน") }
  end

  it 'should redirect to employee if click on name' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    new_window = window_opened_by { click_link "นาง สมศรี เป็นชื่อแอพ" }
    within_window new_window do
      eventually { expect(current_url).to have_content("/somsri_payroll#/employees/#{employees[0].id}") }
    end
  end

  it 'should remove teacher from list' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    find('.fa.fa-times.cursor-pointer.color-red').click
    eventually { expect(page).to_not have_content("นาง สมศรี เป็นชื่อแอพ") }
    # eventually { expect(page).to have_content("จำนวน 0 คน") }
  end

  it 'should display all student in classroom' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_link("นักเรียน")
    eventually { expect(page).to have_content("สมศรี3 ใบเสร็จ สมศรี2 ใบเสร็จ สมศรี1 ใบเสร็จ") }
    # eventually { expect(page).to have_content("จำนวน 3 คน") }
  end

  it 'should save teacher in classroom correctly' do
    num_employee = Employee.where({ classroom_id: classrooms[0].id }).count
    eventually { expect(num_employee).to eq 1 }

    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_button("+ เลือกคุณครู")
    eventually { expect(page).to have_content("นาย สมจิตร เป็นนักมวย") }
    eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
    click_button("+ สร้างคุณครูใหม่")
    sleep(1)
    within('div#create-member-modal') do
      eventually { expect(page).to have_content("สร้างคุณครูใหม่") }
      fill_in "ชื่อ - นามสกุล",  with: "นางสาว ครูใหม่ ไฟแรง"
      fill_in "ชื่อเล่น",  with: "ไฟแรงๆ"
      click_button('บันทึก')
    end
    eventually { expect(page).to have_content("นางสาว ครูใหม่ ไฟแรง (ไฟแรงๆ)") }
    sleep(1)
    within('div#select-member-modal') do
      find('input[data-index="0"]').click
      find('input[data-index="1"]').click
      click_button("ตกลง")
    end
    sleep(1)
    click_button("ตกลง")
    sleep(1)
    num_employee = Employee.where({ classroom_id: classrooms[0].id }).count
    eventually { expect(num_employee).to eq 3 }
  end

  describe 'students tab' do
    before do
      visit "/main#/classroom/#{classrooms[0].id}"
      sleep(1)
      click_link("นักเรียน")
      sleep(1)
    end

    it 'should redirect to student if click on name' do
      new_window = window_opened_by { click_link "สมศรี3 ใบเสร็จ" }
      within_window new_window do
        eventually { expect(current_url).to have_content("/students/#{students[2].id}/edit#/") }
      end
    end

    it 'should remove student from list' do
      first('.fa.fa-times.cursor-pointer.color-red').click
      eventually { expect(page).to_not have_content("สมศรี3 ใบเสร็จ") }
      # eventually { expect(page).to have_content("จำนวน 0 คน") }
    end

    it 'should save teacher in classroom correctly' do
      num_employee = Student.where({ classroom_id: classrooms[0].id }).count
      eventually { expect(num_employee).to eq 3 }

      click_button("+ เลือกนักเรียน")
      eventually { expect(page).to have_content("สมศรี3 ใบเสร็จ") }
      eventually { expect(page).to have_content("สมศรี4 ใบเสร็จ") }
      click_button("+ สร้างนักเรียนใหม่")
      eventually { expect(page).to have_content("สร้างนักเรียนใหม่") }
      sleep(1)
      within('div#create-member-modal') do
        fill_in "ชื่อ - นามสกุล",  with: "สมเสร็จ ใบศรี"
        fill_in "ชื่อเล่น",  with: "สม"
        click_button('บันทึก')
      end
      eventually { expect(page).to_not have_content("บันทึก") }
      sleep(1)
      within('div#select-member-modal') do
        eventually { expect(page).to have_content("สมเสร็จ ใบศรี (สม)") }
        find('input[data-index="0"]').click
        find('input[data-index="1"]').click
        click_button("ตกลง")
      end
      sleep(1)
      click_button("ตกลง")
      sleep(1)
      num_employee = Student.where({ classroom_id: classrooms[0].id }).count
      eventually { expect(num_employee).to eq 5 }
    end
  end
end
