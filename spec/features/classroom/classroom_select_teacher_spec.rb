describe 'Classroom Select Teacher', js: true do

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

  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    employees
  end

  it 'should display select teacher pop-up' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_button("+ เลือกคุณครู")
    eventually { expect(page).to have_content("นาย สมจิตร เป็นนักมวย") }
    eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
    within('div#select-member-modal') do
      eventually { expect(page).to_not have_content("นาง สมศรี เป็นชื่อแอพ") }
    end
    # eventually { expect(page).to have_content("จำนวน 1 คน") }
  end

  it 'should click teacher link and goto employee' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_button("+ เลือกคุณครู")
    eventually { expect(page).to have_content("นาย สมจิตร เป็นนักมวย") }
    eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
    within('div#select-member-modal') do
      eventually { expect(page).to_not have_content("นาง สมศรี เป็นชื่อแอพ") }
    end

    new_window = window_opened_by { click_link "นาย สมจิตร เป็นนักมวย" }
    within_window new_window do
      eventually { expect(current_url).to have_content("/somsri_payroll#/employees/2") }
    end
  end

  it 'should select teacher' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_button("+ เลือกคุณครู")
    eventually { expect(page).to have_content("นาย สมจิตร เป็นนักมวย") }
    eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
    within('div#select-member-modal') do
      eventually { expect(page).to_not have_content("นาง สมศรี เป็นชื่อแอพ") }
    end
    sleep(1)
    within('div#select-member-modal') do
      find('input[data-index="0"]').click
      click_button("ตกลง")
    end

    eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
    eventually { expect(page).to have_content("นาง สมศรี เป็นชื่อแอพ") }
  end

  it 'should select all teachers' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_button("+ เลือกคุณครู")
    eventually { expect(page).to have_content("นาย สมจิตร เป็นนักมวย") }
    eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
    within('div#select-member-modal') do
      eventually { expect(page).to_not have_content("นาง สมศรี เป็นชื่อแอพ") }
    end
    sleep(1)
    within('div#select-member-modal') do
      find('input[name="btSelectAll"]').click
      click_button("ตกลง")
    end

    eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
    eventually { expect(page).to have_content("นาย สมจิตร เป็นนักมวย") }
    eventually { expect(page).to have_content("นาง สมศรี เป็นชื่อแอพ") }
  end

  it 'should unselect all teachers' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_button("+ เลือกคุณครู")
    eventually { expect(page).to have_content("นาย สมจิตร เป็นนักมวย") }
    eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
    within('div#select-member-modal') do
      eventually { expect(page).to_not have_content("นาง สมศรี เป็นชื่อแอพ") }
    end
    sleep(1)
    within('div#select-member-modal') do
      find('input[name="btSelectAll"]').click
      eventually { expect(all('tr.selected').count).to eq 2 }

      find('input[name="btSelectAll"]').click
      eventually { expect(all('tr.selected').count).to eq 0 }
      click_button("ตกลง")
    end

    eventually { expect(page).to_not have_content("นาง สมใจ เป็นคน") }
    eventually { expect(page).to_not have_content("นาย สมจิตร เป็นนักมวย") }
    eventually { expect(page).to have_content("นาง สมศรี เป็นชื่อแอพ") }
  end

  it 'should search teachers' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_button("+ เลือกคุณครู")
    eventually { expect(page).to have_content("นาย สมจิตร เป็นนักมวย") }
    eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
    within('div#select-member-modal') do
      eventually { expect(page).to_not have_content("นาง สมศรี เป็นชื่อแอพ") }
    end
    sleep(1)
    within('div#select-member-modal') do
      find('input[placeholder="Search"]').set("นาง")
      eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
      eventually { expect(page).to_not have_content("นาย สมจิตร เป็นนักมวย") }
    end
  end
end
