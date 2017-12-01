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

  it 'should create teacher' do
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

    employee = Employee.where({
      prefix_thai: "นางสาว",
      first_name_thai: "ครูใหม",
      last_name_thai: "ไฟแรง",
      nickname: "ไฟแรงๆ"
    })
    eventually { expect(employee).to_not eq nil }
  end

  it 'should cancel create teacher' do
    visit "/main#/classroom/#{classrooms[0].id}"
    sleep(1)
    click_button("+ เลือกคุณครู")
    eventually { expect(page).to have_content("นาย สมจิตร เป็นนักมวย") }
    eventually { expect(page).to have_content("นาง สมใจ เป็นคน") }
    click_button("+ สร้างคุณครูใหม่")
    sleep(1)
    within('div#create-member-modal') do
      eventually { expect(page).to have_content("สร้างคุณครูใหม่") }
      click_button('ยกเลิก')
    end
    sleep(1)
    eventually { expect(page).to_not have_content("ชื่อเล่น") }
  end


end
