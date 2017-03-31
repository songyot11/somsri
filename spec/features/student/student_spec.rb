describe 'Student', js: true do

  let(:user) { user = User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:student) do
    [
      student1 = Student.make!({
        first_name: 'สมศรี',
        last_name: 'ใบเสร็จ'
      })
    ]
  end

  before do
    user.add_role :admin
    login_as(user, scope: :user)
    student
  end

  it 'should access to student page' do
    visit '/students#/'
    sleep(1)

    eventually { expect(page).to have_content("นักเรียน") }
  end

  it 'should graduate student' do
    visit '/students#/'
    sleep(1)
    find('#student_graduated').click
    sleep(1)
    page.accept_alert
    sleep(1)
    student[0].reload

    eventually { expect(page).to have_content ("จบการศึกษา") }
    eventually { expect(student[0].status).to eq("จบการศึกษา") }
  end

  it 'should resign student' do
    visit '/students#/'
    sleep(1)
    find('#student_resign').click
    sleep(1)
    page.accept_alert
    sleep(1)
    student[0].reload

    eventually { expect(page).to have_content ("ลาออก") }
    eventually { expect(student[0].status).to eq("ลาออก") }
  end

  it 'should delete student' do
    visit '/students#/'
    sleep(1)
    eventually { expect(page).to have_content("สมศรี ใบเสร็จ") }
    sleep(1)
    find('#student_destroy').click
    sleep(1)
    page.accept_alert

    eventually { expect(page).to have_no_content("สมศรี ใบเสร็จ") }
  end

  it 'should restore student' do
    visit '/students#/'
    sleep(1)
    find('#student_resign').click
    sleep(1)
    page.accept_alert
    sleep(1)
    find('#student_restore').click
    sleep(1)

    eventually { expect(page).to have_content("กำลังศึกษา") }
  end
end
