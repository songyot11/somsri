describe 'Invoice', js: true do
  let(:school) do
    School.make!({ name: "โรงเรียนแห่งหนึ่ง" })
  end

  let(:user) { user = User.make!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:grade){grade = Grade.make!(
    name: "Kindergarten 1"
  )}

  let(:gender)do
  [
    Gender.make!(name: "Female"),
    Gender.make!(name: "Male")
  ]
  end

  let(:invoice_status_1) { InvoiceStatus.make! name: 'Active' }
  let(:invoice_status_2) { InvoiceStatus.make! name: 'Canceled' }

  let(:grade) do
    Grade.make!({name: "Kindergarten 1"})
  end

  let(:classroom) do
    Classroom.make!({name: "1A", grade_id: grade.id})
  end

  let(:students) do
    [
      Student.make!({
        first_name: 'มั่งมี',
        last_name: 'ศรีสุข',
        nickname: 'รวย' ,
        gender_id: 1 ,
        grade_id: grade.id ,
        classroom: classroom ,
        classroom_number: 13 ,
        student_number: 23 ,

      }),
      Student.make!({
        first_name: 'สมศรี',
        last_name: 'ณ บานาน่าโค๊ดดิ้ง',
        nickname: 'กล้วย' ,
        gender_id: 2 ,
        grade_id: grade.id ,
        classroom: classroom ,
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
        classroom: classroom ,
        classroom_number: 14 ,
        student_number: 21 ,
        birthdate: Time.now

      })
    ]
  end

  let(:student_no_number) do
    Student.make!({
      first_name: 'มั่งไม่มี',
      last_name: 'เลขนักเรียน',
      nickname: 'ไม่' ,
      gender_id: 1 ,
      grade_id: grade.id ,
      classroom: classroom
    })
  end

  let(:parents) do
    [
      Parent.make!({full_name: 'ฉันเป็น สุภาพบุรุษนะครับ'}),
      Parent.make!({full_name: 'ฉันเป็น ผู้ปกครอง'}),
      Parent.make!({full_name: 'ฉันเป็น สุภาพสตรีค๊ะ'})
    ]
  end

  let(:studentsparent) do
    [
      StudentsParent.make!({student_id: students[0].id , parent_id: parents[0].id}),
      StudentsParent.make!({student_id: students[1].id , parent_id: parents[1].id}),
      StudentsParent.make!({student_id: students[2].id , parent_id: parents[2].id})
    ]
  end

  let(:studentsparent_no_number) do
    StudentsParent.make!({student_id: student_no_number.id , parent_id: parents[0].id})
  end

  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    grade
    gender
    invoice_status_1
    invoice_status_2
    studentsparent
  end

  it 'should create invoice' do
    visit 'somsri_invoice#/invoice'
    sleep(1)
    fill_in 'student_code', with: "21"
    click_link('21 - สมศรี ณ บานาน่าโค๊ดดิ้ง (กั้ง)')
    click_on('ชำระเงิน')
    sleep(1)
    expect(page).to have_content("ใบเสร็จรับเงิน")
    expect(page).to have_content("สมศรี ณ บานาน่าโค๊ดดิ้ง")
    expect(page).to have_content("ค่าธรรมเนียมการศึกษา")
  end

  it 'should not create invoice when student has not number' do
    student_no_number
    studentsparent_no_number
    student_count = Student.count
    visit 'somsri_invoice#/invoice'
    sleep(1)
    fill_in 'student_name', with: "มั่งไม่มี"
    click_link('มั่งไม่มี เลขนักเรียน (ไม่)')
    click_on('ชำระเงิน')
    sleep(1)
    expect(page).to have_content("ใบเสร็จรับเงิน")
    expect(page).to have_content("มั่งไม่มี เลขนักเรียน")
    expect(page).to have_content("ค่าธรรมเนียมการศึกษา")
    expect(page).to have_content("1A")
    expect(Student.count).to eq student_count
  end

  it 'should create invoice with student and parent' do
    visit 'somsri_invoice#/invoice'
    student_amount = Student.count
    parent_amount = Parent.count
    sleep(1)
    fill_in 'student_name', with: "9S"
    fill_in 'parent_name', with: "2B"
    click_on('ชำระเงิน')
    sleep(1)
    expect(page).to have_content("ใบเสร็จรับเงิน")
    expect(page).to have_content("9S")
    expect(page).to have_content("2B")
    expect(Student.count).to eq(student_amount + 1)
    expect(Parent.count).to eq(parent_amount + 1)
  end

  it 'should create invoice with only student if parent exist' do
    visit 'somsri_invoice#/invoice'
    student_amount = Student.count
    parent_amount = Parent.count
    sleep(1)
    fill_in 'student_name', with: "9S"
    fill_in 'parent_name', with: "ฉันเป็น สุภาพบุรุษนะครับ"
    click_on('ชำระเงิน')
    sleep(1)
    expect(page).to have_content("ใบเสร็จรับเงิน")
    expect(page).to have_content("9S")
    expect(page).to have_content("ฉันเป็น สุภาพบุรุษนะครับ")
    expect(Student.count).to eq(student_amount + 1)
    expect(Parent.count).to eq(parent_amount)
  end

  it 'should create only invoice if student exist' do
    visit 'somsri_invoice#/invoice'
    student_amount = Student.count
    sleep(1)
    fill_in 'student_code', with: "21"
    click_link('21 - สมศรี ณ บานาน่าโค๊ดดิ้ง (กั้ง)')
    sleep(1)
    click_on('ชำระเงิน')
    sleep(1)
    expect(page).to have_content("ใบเสร็จรับเงิน")
    expect(page).to have_content("สมศรี ณ บานาน่าโค๊ดดิ้ง")
    expect(Student.count).to eq(student_amount)

    visit "/students/#{students[1].id}/edit#/"
    click_link('ข้อมูลใบเสร็จ')
    sleep(1)
    eventually { expect(page).to have_content("Kindergarten 1 (1A) 48,900.00") }
  end

end
