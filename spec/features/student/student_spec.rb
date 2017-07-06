describe 'Student', js: true do

  let(:school) do
    School.make!({ name: "โรงเรียนแห่งหนึ่ง" })
  end

  let(:user) { user = User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:invoice_status_1) { InvoiceStatus.make! name: 'Active' }
  let(:invoice_status_2) { InvoiceStatus.make! name: 'Canceled' }

  let(:grade){grade = Grade.create(
    name: "Kindergarten 1"
  )}

  let(:student) do
    [
      student1 = Student.make!({
        first_name: 'สมศรี',
        last_name: 'ใบเสร็จ',
        grade_id: grade.id,
        classroom_number: 106,
        student_number: 9006,
        birthdate: Time.now
      })
    ]
  end

  let(:parent) do
    [
      Parent.make!({full_name: 'ฉันเป็น สุภาพบุรุษนะครับ', mobile: "080-0987654"})
    ]
  end

  let(:relationships) do
    [
      Relationship.make!({ name: 'Father' }),
      Relationship.make!({ name: 'Mother' })
    ]
  end

  let(:studentsparent) do
    [
      StudentsParent.make!({student_id: student[0].id , parent_id: parent[0].id, relationship_id: relationships[0].id})
    ]
  end

  let(:invoice) { inv1 = Invoice.make!({
    student_id: student[0].id,
    user_id: user.id,
    parent_id: parent[0].id,
    invoice_status_id:  invoice_status_1.id,
    school_year: "2560",
    semester: "1",
    line_items: [
      LineItem.make!(:tuition, amount: 48000),
      LineItem.make!(amount: 3000),
      LineItem.make!(amount: 750)
    ]
  })

}

  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    studentsparent
    invoice_status_1
    invoice_status_2
    invoice
  end

  it 'should access to student page' do
    visit '/students#/'
    sleep(1)
    eventually { expect(page).to have_content("นักเรียน") }
  end

  it 'should remove student' do
    visit "/students/#{student[0].id}/edit#/"
    sleep(1)
    first('#student_remove').click
    sleep(1)
    page.accept_alert
    sleep(1)
    student[0].reload

    eventually { expect(page).to_not have_content ("สมศรี") }
    eventually { expect(student[0].deleted_at.blank?).to eq false }
  end

  it 'should see student on invoice slip, although student deleted' do
    visit "/students/#{student[0].id}/edit#/"
    sleep(1)
    first('#student_remove').click
    sleep(1)
    page.accept_alert
    sleep(1)

    visit "/somsri_invoice#/invoice/#{invoice.id}/slip"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see student on invoice_report, although student deleted' do
    visit "/students/#{student[0].id}/edit#/"
    sleep(1)
    first('#student_remove').click
    sleep(1)
    page.accept_alert
    sleep(1)

    visit '/somsri_invoice#/invoice_report'
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see student on student_report, although student deleted' do
    visit "/students/#{student[0].id}/edit#/"
    sleep(1)
    first('#student_remove').click
    sleep(1)
    page.accept_alert
    sleep(1)
    visit "/somsri_invoice#/student_report"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should create student with list' do
    visit '/students/new#/'
    sleep(1)
    page.fill_in 'ชื่อ-นามสกุล', :with => 'นักเรียนเพิ่มใหม่'
    page.fill_in 'ชื่อเล่น', :with => 'ใหม่'
    page.fill_in 'Full Name', :with => 'Nakreanpermmai'
    page.fill_in 'Nick Name', :with => 'Mai'
    page.fill_in 'ห้อง', :with => '2B'
    sleep(1)
    click_button("บันทึก")
    sleep(1)
    new_student = Student.where(full_name: "นักเรียนเพิ่มใหม่").first
    eventually { expect(new_student.student_lists.size).to eq(1) }
    eventually { expect(new_student.student_lists[0].list.name).to eq("2B") }
  end

  it 'should create list when add classroom to student' do
    visit "/students/#{student[0].id}/edit#/"
    sleep(1)
    page.fill_in 'ห้อง', :with => '2B'
    sleep(1)
    click_button("บันทึก")
    sleep(1)

    new_student = Student.where(id: student[0].id).first
    eventually { expect(new_student.student_lists.length).to eq(1) }
    eventually { expect(new_student.student_lists[0].list.name).to eq("2B") }
  end

  it 'should display parent mobile' do
    visit "/students/#{student[0].id}/edit#/"
    eventually { expect(find('#mobile0').value).to eq("080-0987654") }
  end

  it 'should edit parent mobile' do
    visit "/students/#{student[0].id}/edit#/"
    find('#mobile0').set("080-000000")
    click_button("บันทึก")
    sleep(1)
    visit "/students/#{student[0].id}/edit#/"
    sleep(1)
    eventually { expect(find('#mobile0').value).to eq("080-000000") }
  end
end
