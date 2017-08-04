describe 'Invoice-Report', js: true do

  let(:school) do
    School.make!({ name: "โรงเรียนแห่งหนึ่ง" })
  end

  let(:user) { user = User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:invoice_status_1) { InvoiceStatus.make! name: 'Active' }
  let(:invoice_status_2) { InvoiceStatus.make! name: 'Canceled' }

  let(:parent) do
    [
      parent1 = Parent.make!({
        full_name: 'สมศรี ใบเสร็จ'
      })
    ]
  end

  let(:parent_only) do
    [
      parent2 = Parent.make!({
        full_name: 'สมชาย ใบกระท่อม'
      })
    ]
  end

  let(:grade){grade = Grade.create(
    name: "Kindergarten 1"
  )}

  let(:student) do
    [
      student1 = Student.make!({
        first_name: 'ลูกศรี',
        last_name: 'ใบเสร็จ',
        grade_id: grade.id,
        classroom_number: 106,
        student_number: 9006,
        birthdate: Time.now
      })
    ]
  end

  let(:studentsparent) do
    [
      StudentsParent.make!({student_id: student[0].id , parent_id: parent[0].id, relationship_id: relationships[0].id})
    ]
  end

  let(:relationships) do
    [
      Relationship.make!({ name: 'Father' }),
      Relationship.make!({ name: 'Mother' })
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
  })}


  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    studentsparent
    invoice_status_1
    invoice_status_2
    invoice
  end

  it 'should access to parent page' do
    visit '/parents#/'
    sleep(1)
    eventually { expect(page).to have_content("ผู้ปกครอง") }
  end

  it 'should goto student edit by click link' do
    visit '/parents#/'
    sleep(1)
    click_link('ลูกศรี ใบเสร็จ')
    sleep(1)
    eventually { expect(page).to have_content("แก้ไขนักเรียน") }
    eventually { expect(find("#student_full_name").value).to eq("ลูกศรี ใบเสร็จ") }
  end

  it 'should see all parent in system' do
    parent_only
    visit '/parents#/'
    sleep(1)
    eventually { expect(page).to have_content("สมศรี ใบเสร็จ") }
    eventually { expect(page).to have_content("สมชาย ใบกระท่อม") }
  end

  it 'should archive parent' do
    visit "/parents/#{parent[0].id}/edit#/"
    sleep(1)
    first('#parent_archive').click
    sleep(1)
    page.accept_alert
    sleep(1)
    parent[0].reload
    sleep(1)
    eventually { expect(parent[0].deleted_at.blank?).to eq(false) }
  end

  it 'should see parent on invoice slip, although parent is deleted' do
    visit "/parents/#{parent[0].id}/edit#/"
    sleep(1)
    first('#parent_archive').click
    sleep(1)
    page.accept_alert
    sleep(1)
    visit "/somsri_invoice#/invoice/#{invoice.id}/slip"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see parent on student_report, although parent is deleted' do
    visit "/parents/#{parent[0].id}/edit#/"
    sleep(1)
    first('#parent_archive').click
    sleep(1)
    page.accept_alert
    sleep(1)
    visit "/somsri_invoice#/student_report"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see parent on invoice_report, although parent is deleted' do
    visit "/parents/#{parent[0].id}/edit#/"
    sleep(1)
    first('#parent_archive').click
    sleep(1)
    page.accept_alert
    sleep(1)
    visit '/somsri_invoice#/invoice_report'
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should create parent' do
    visit "/parents/new#/"
    sleep(1)
    page.fill_in 'ชื่อ-นามสกุล', :with => 'มานี มีตา'
    click_on('บันทึก')
    sleep(1)
    eventually { expect(Parent.where(full_name: 'มานี มีตา').count).to eq 1 }
  end

  it 'should edit parent' do
    visit "/parents/#{parent[0].id}/edit#/"
    sleep(1)
    page.fill_in 'ชื่อ-นามสกุล', :with => 'มานี มีตา'
    click_on('บันทึก')
    sleep(1)
    eventually { expect(Parent.where(full_name: 'มานี มีตา').count).to eq 1 }
  end

end
