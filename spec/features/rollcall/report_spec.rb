describe 'RollCall report', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  let(:employee) do
    Employee.make!({ school_id: school.id, pin: "1111" })
  end

  let(:grade) { Grade.make!(name: 'K1') }

  let(:classrooms) do
    [
      Classroom.make!({name: "1A", grade_id: grade.id}),
      Classroom.make!({name: "1B", grade_id: grade.id})
    ]
  end

  let(:students) do
    [
      Student.make!({
        first_name: 'มั่งมี',
        last_name: 'ศรีสุข',
        nickname: 'รวย' ,
        gender_id: 1 ,
        grade_id: grade.id ,
        classroom: classrooms[0] ,
        classroom_number: 13 ,
        student_number: 23 ,
      }),
      Student.make!({
        first_name: 'สมศรี',
        last_name: 'ณ บานาน่าโค๊ดดิ้ง',
        nickname: 'กล้วย' ,
        gender_id: 2 ,
        grade_id: grade.id ,
        classroom: classrooms[0] ,
        classroom_number: 14 ,
        student_number: 22 ,
        birthdate: Time.now
      }),
      Student.make!({
        first_name: 'สมศรี',
        last_name: 'ณ บานาน่าโค๊ดดิ้ง',
        nickname: 'กั้ง' ,
        gender_id: 2 ,
        grade_id: grade.id ,
        classroom: classrooms[1] ,
        classroom_number: 14 ,
        student_number: 21 ,
        birthdate: Time.now
      })
    ]
  end

  let(:lists) do
    [
      List.make!({ name: "1A" }),
      List.make!({ name: "1B" })
    ]
  end

  let(:teacher_attendance_lists) do
    [
      TeacherAttendanceList.make!({ list_id: lists[0].id, employee_id: employee.id}),
      TeacherAttendanceList.make!({ list_id: lists[1].id, employee_id: employee.id})
    ]
  end

  let(:student_lists) do
    [
      StudentList.make!({ student_id: students[0].id, list_id: lists[0].id }),
      StudentList.make!({ student_id: students[1].id, list_id: lists[0].id }),
      StudentList.make!({ student_id: students[2].id, list_id: lists[1].id })
    ]
  end

  let(:roll_calls) do
    [
      RollCall.make!({ student_id: students[0].id, list_id: lists[0].id, round: "afternoon", status: "3", check_date: "2017-03-28" }),
      RollCall.make!({ student_id: students[0].id, list_id: lists[0].id, round: "morning", status: "3", check_date: "2017-04-28" }),
      RollCall.make!({ student_id: students[1].id, list_id: lists[0].id, round: "morning", status: "0", check_date: "2017-03-28" }),
      RollCall.make!({ student_id: students[2].id, list_id: lists[1].id, round: "morning", status: "3", check_date: "2017-03-28" })
    ]
  end

  before do
    SiteConfig.make!({ enable_rollcall: true })
    lists
    student_lists
    roll_calls
    user.add_role :admin
    login_as(user, scope: :user)
    teacher_attendance_lists
  end

  it 'should go to rollcall report' do
    visit "/somsri_rollcall#/report"
    sleep(4)
    expect(page).to have_selector('.fa.fa-check', count: 1)
    expect(page).to have_selector('.fa.fa-times', count: 1)
  end

  it 'should go to rollcall report' do
    visit "/somsri_rollcall#/report"
    sleep(1)
    find('.ng-binding', :text => '1A').click
    sleep(1)
    click_link('1B')
    sleep(1)
    expect(page).to have_selector('.fa.fa-check', count: 1)
    expect(page).not_to have_selector('.fa.fa-times')
  end

  it 'should go to rollcall report' do
    skip("Capybara webkit doesn't support date.toLocaleDateString()")
    visit "/somsri_rollcall#/report"
    sleep(1)
    find('.ng-binding', :text => 'มีนาคม 2560').click
    sleep(1)
    click_link('เมษายน 2560')
    sleep(1)
    expect(page).to have_selector('.fa.fa-check', count: 1)
    expect(page).not_to have_selector('.fa.fa-times')
  end

  it 'should go to rollcall report' do 
    skip("Capybara webkit doesn't support date.toLocaleDateString()")
    visit "/somsri_rollcall#/report"
    find("#navbarDropdownMenuLink").click
    find('.fa-commenting-o').hover
    find("#en").click
    sleep(1) 
    sleep(1)
    visit "/somsri_rollcall#/report"
    find('.ng-binding', :text => 'March 2017').click
    sleep(1)
    click_link('April 2017')
    sleep(1)
    expect(page).to have_selector('.fa.fa-check', count: 1)
    expect(page).not_to have_selector('.fa.fa-times')
  end
end
