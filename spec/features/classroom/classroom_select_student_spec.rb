describe 'Classroom Select Student', js: true do

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
    sleep(1)
  end

  it 'should display select student pop-up' do
    within('div#select-member-modal') do
      eventually { expect(page).to_not have_content("สมศรี1 ใบเสร็จ") }
      eventually { expect(page).to_not have_content("สมศรี2 ใบเสร็จ") }
      eventually { expect(page).to_not have_content("สมศรี3 ใบเสร็จ") }
      eventually { expect(page).to have_content("สมศรี4 ใบเสร็จ") }
      eventually { expect(page).to have_content("สมศรี5 ใบเสร็จ") }
      eventually { expect(page).to have_content("จำนวนที่เลือก 0 คน") }
    end
  end

  it 'should click student link and goto employee' do
    new_window = window_opened_by { click_link "สมศรี4 ใบเสร็จ" }
    within_window new_window do
      eventually { expect(current_url).to have_content("/students/#{students[3].id}/edit#/") }
    end
  end

  it 'should select student' do
    within('div#select-member-modal') do
      find('input[data-index="0"]').click
      click_button("ตกลง")
    end
    sleep(1)
    eventually { expect(find("#student-list tr[data-index='3']")).to_not eq nil }
  end

  it 'should select all teachers' do
    eventually { expect(page).to have_content("สมศรี4 ใบเสร็จ") }
    eventually { expect(page).to have_content("สมศรี5 ใบเสร็จ") }
    within('div#select-member-modal') do
      find('input[name="btSelectAll"]').click
      eventually { expect(page).to have_content("จำนวนที่เลือก 2 คน") }
      click_button("ตกลง")
    end
    eventually { expect(page).to have_content("สมศรี1 ใบเสร็จ") }
    eventually { expect(page).to have_content("สมศรี2 ใบเสร็จ") }
    eventually { expect(page).to have_content("สมศรี3 ใบเสร็จ") }

    eventually { expect(page).to have_content("สมศรี4 ใบเสร็จ") }
    eventually { expect(page).to have_content("สมศรี5 ใบเสร็จ") }
  end

  it 'should unselect all teachers' do
    within('div#select-member-modal') do
      find('input[name="btSelectAll"]').click
      eventually { expect(all('tr.selected').count).to eq 2 }

      find('input[name="btSelectAll"]').click
      eventually { expect(all('tr.selected').count).to eq 0 }
      click_button("ตกลง")
    end

    eventually { expect(page).to have_content("สมศรี1 ใบเสร็จ") }
    eventually { expect(page).to have_content("สมศรี2 ใบเสร็จ") }
    eventually { expect(page).to have_content("สมศรี3 ใบเสร็จ") }

    eventually { expect(page).to_not have_content("สมศรี4 ใบเสร็จ") }
    eventually { expect(page).to_not have_content("สมศรี5 ใบเสร็จ") }
  end

  it 'should search teachers' do
    within('div#select-member-modal') do
      find('input[placeholder="Search"]').set("5")
      eventually { expect(page).to have_content("สมศรี5 ใบเสร็จ") }
      eventually { expect(page).to_not have_content("สมศรี4 ใบเสร็จ") }
    end
  end
end
