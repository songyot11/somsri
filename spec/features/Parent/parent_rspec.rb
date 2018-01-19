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

  let(:parent_more) do
    [
      Parent.make!({
        full_name: 'แกรน เนตโต้'
      }),
      Parent.make!({
        full_name: 'เรน โบว์'
      }),
      Parent.make!({
        full_name: 'แฟรงค์ คลาวด์'
      }),
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
    eventually { expect(page).to have_content("+ เพิ่มชื่อผู้ปกครอง") }
    eventually { expect(find("#student_full_name").value).to eq("ลูกศรี ใบเสร็จ") }
  end

  it 'should not display soft deleted parent' do
    parent_only[0].destroy
    visit '/parents#/'
    sleep(1)
    eventually { expect(page).to have_content("สมศรี ใบเสร็จ") }
    eventually { expect(page).to_not have_content("สมชาย ใบกระท่อม") }
  end

  it 'should see all parent in system' do
    parent_only
    visit '/parents#/'
    sleep(1)
    eventually { expect(page).to have_content("สมศรี ใบเสร็จ") }
    eventually { expect(page).to have_content("สมชาย ใบกระท่อม") }
  end

  it 'should go to edit parent page' do
    visit "/parents"
    sleep(1)
    first("#options#{parent[0].id}").click
    first("a[href=\"/parents/#{parent[0].id}/edit\"]").click
    sleep(1)
    eventually { expect(page).to have_content("สมศรี ใบเสร็จ") }
    eventually { expect(page).to have_content("ชื่อ-นามสกุล ชื่อเล่น") }
    eventually { expect(page).to have_content("เพิ่มชื่อนักเรียน") }
  end

  it 'should archive parent' do
    visit "/parents"
    sleep(1)
    first("#options#{parent[0].id}").click
    first("a[onclick=\"openDeletedParentModal(#{parent[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการลบผู้ปกครองคนนี้ใช่หรือไม่?") }
    find("a", text: "ตกลง").click
    sleep(1)

    parent[0].reload
    eventually { expect(parent[0].deleted_at.blank?).to be_falsey }

    visit "/parents"
    sleep(1)
    eventually { expect(page).to_not have_content("สมศรี ใบเสร็จ") }
  end

  it 'should search and change page to other parent' do
    parent_more
    visit "/parents/#{parent[0].id}/edit#/"
    eventually { expect(page).to have_content ("สมศรี ใบเสร็จ") }
    sleep(1)
    first('.fa.fa-search').click
    sleep(1)
    find('.search-autocomplete', text: "แฟรงค์ คลาวด์").click
    sleep(1)
    eventually { expect(page).to have_content ("แฟรงค์ คลาวด์") }
  end

  it 'should warning if change page while parent data changed and submit' do
    parent_more
    visit "/parents/#{parent_more[1].id}/edit#/"
    sleep(1)
    fill_in 'ชื่อ-นามสกุล', :with => 'ชื่อใหม่'
    sleep(1)
    first('.fa.fa-search').click
    sleep(1)
    first('.search-autocomplete').click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?") }
    sleep(1)
    find("#force-change-page").click
    sleep(1)
    eventually { expect(page).to_not have_content ("เรน โบว์") }
  end

  it 'should warning if change page while parent data changed and cancel' do
    parent_more
    visit "/parents/#{parent_more[1].id}/edit#/"
    sleep(1)
    fill_in 'ชื่อ-นามสกุล', :with => 'ชื่อใหม่'
    sleep(1)
    first('.fa.fa-search').click
    sleep(1)
    first('.search-autocomplete').click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?") }
    click_button("ยกเลิก")
    sleep(1)
    eventually { expect(page).to have_content ("เรน โบว์") }
  end

  it 'should warning if click cancel button while parent data changed and go' do
    parent_more
    visit "/parents/#{parent_more[1].id}/edit#/"
    sleep(1)
    fill_in 'ชื่อ-นามสกุล', :with => 'ชื่อใหม่'
    sleep(1)
    first('a', text: "ยกเลิก").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?") }
    sleep(1)
    find("#force-change-page").click
    sleep(1)
    eventually { expect(page).to have_content ("ผู้ปกครอง") }
    eventually { expect(page).to have_content ("Export") }
  end

  it 'should warning if click cancel button while parent data changed and cancel' do
    parent_more
    visit "/parents/#{parent_more[1].id}/edit#/"
    sleep(1)
    fill_in 'ชื่อ-นามสกุล', :with => 'ชื่อใหม่'
    sleep(1)
    first('a', text: "ยกเลิก").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?") }
    click_button("ยกเลิก")
    sleep(1)
    eventually { expect(page).to have_content ("เรน โบว์") }
  end

  it 'should see parent on invoice slip, although parent is deleted' do
    visit "/parents"
    sleep(1)
    first("#options#{parent[0].id}").click
    first("a[onclick=\"openDeletedParentModal(#{parent[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการลบผู้ปกครองคนนี้ใช่หรือไม่?") }
    find("a", text: "ตกลง").click
    sleep(1)

    parent[0].reload
    eventually { expect(parent[0].deleted_at.blank?).to be_falsey }

    visit "/somsri_invoice#/invoice/#{invoice.id}/slip"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี ใบเสร็จ") }
  end

  it 'should see parent on student_report, although parent is deleted' do
    visit "/parents"
    sleep(1)
    first("#options#{parent[0].id}").click
    first("a[onclick=\"openDeletedParentModal(#{parent[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการลบผู้ปกครองคนนี้ใช่หรือไม่?") }
    find("a", text: "ตกลง").click
    sleep(1)

    parent[0].reload
    eventually { expect(parent[0].deleted_at.blank?).to be_falsey }
    sleep(1)
    visit "/somsri_invoice#/student_report"
    sleep(1)
    eventually { expect(page).to have_content ("ลูกศรี ใบเสร็จ") }
  end

  it 'should see parent on invoice_report, although parent is deleted' do
    visit "/parents"
    sleep(1)
    first("#options#{parent[0].id}").click
    first("a[onclick=\"openDeletedParentModal(#{parent[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการลบผู้ปกครองคนนี้ใช่หรือไม่?") }
    find("a", text: "ตกลง").click
    sleep(1)

    parent[0].reload
    eventually { expect(parent[0].deleted_at.blank?).to be_falsey }
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

  it 'should disable parent\'s mobile and relationship when not select parent' do
    visit "/parents/#{parent_more[0].id}/edit#/"
    sleep(1)
    find("#student-link").click
    sleep(1)
    eventually { expect(find('#relationship0')[:disabled]).to eq true }
    eventually { expect(find('#relationship1')[:disabled]).to eq true }
  end

end
