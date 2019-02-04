describe 'Login', js: true do

  let(:schools) do
    [
      School.make!({ name: "โรงเรียนแห่งหนึ่ง" }),
      School.make!({ name: "โรงเรียนแห่งสอง" })
    ]
  end

  let(:users) do
    [
      User.make!({ school_id: schools[0].id }),
      User.make!({ school_id: schools[1].id })
    ]
  end

  let(:employees) do
    [
      Employee.make!({
        school_id: schools[0].id,
        first_name: "Somsri",
        middle_name: "Is",
        last_name: "Appname",
        prefix: "Mrs.",
        first_name_thai: "สมศรี",
        last_name_thai: "เป็นชื่อแอพ",
        prefix_thai: "นาง",
        salary: 50000
      }),
      Employee.make!({
        school_id: schools[1].id,
        first_name: "Somchit",
        middle_name: "Is",
        last_name: "Boxing",
        prefix: "Mr",
        first_name_thai: "สมจิตร",
        last_name_thai: "เป็นนักมวย",
        prefix_thai: "นาย",
        salary: 20000
      })
    ]
  end

  let(:payrolls) do
    [
      Payroll.make!({
        employee_id: employees[0].id,
        salary: 50000,
        tax: 100,
        advance_payment: 2000,
        allowance: 3000,
        effective_date: DateTime.now
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 50000,
        tax: 1000,
        position_allowance: 10000,
        fee_etc: 200,
        effective_date: DateTime.now
      })
    ]
  end

  before do
    users[0].add_role :admin
    users[1].add_role :admin
    payrolls
  end

  it 'should not go anywhere if user not authentication' do
    visit "/somsri_payroll#/employees"
    expect(page).to have_current_path '/users/sign_in'
    expect(page).to have_button 'Sign in'

    visit "/somsri_payroll#/reports"
    expect(page).to have_current_path '/users/sign_in'
    expect(page).to have_button 'Sign in'

    visit "/somsri_payroll#/employees/1"
    expect(page).to have_current_path '/users/sign_in'
    expect(page).to have_button 'Sign in'
  end

  it 'should able to authentication' do
    visit new_user_session_path
    find('#user_email').set(users[0].email)
    find('#user_password').set(users[0].password)
    click_button('Sign in')
    expect(page).to have_current_path "/"
    expect(page).to have_content "#{users[0].name}"
  end

  it 'should logo not empty' do
    visit "/"
    expect(page).to have_css("img[src*='somsri_logo.png']")
  end

end
