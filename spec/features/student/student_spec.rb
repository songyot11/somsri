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

  let(:classrooms) do
    [
      Classroom.make!({name: "2A", grade_id: grade.id}),
      Classroom.make!({name: "2B", grade_id: grade.id})
    ]
  end

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

  let(:student_more) do
    [
      Student.make!({
        first_name: 'แกรน',
        last_name: 'เนตโต้',
        grade_id: grade.id,
        classroom_number: 101,
        student_number: 3001,
        birthdate: Time.now
      }),
      Student.make!({
        first_name: 'เรน',
        last_name: 'โบว์',
        grade_id: grade.id,
        classroom_number: 102,
        student_number: 3002,
        birthdate: Time.now
      }),
      Student.make!({
        first_name: 'แฟรงค์',
        last_name: 'คลาวด์',
        grade_id: grade.id,
        classroom_number: 103,
        student_number: 3003,
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

  let(:gender)do
    [
      Gender.make!(name: "Female"),
      Gender.make!(name: "Male")
    ]
  end

  let(:studentsparent) do
    [
      StudentsParent.make!({student_id: student[0].id , parent_id: parent[0].id, relationship_id: relationships[0].id})
    ]
  end

  let(:invoice) {
    inv1 = Invoice.make!({
      student_id: student[0].id,
      user_id: user.id,
      parent_id: parent[0].id,
      invoice_status_id:  invoice_status_1.id,
      school_year: Time.current.year + 543,
      student_name: "สมศรี ใบเสร็จ",
      semester: "1",
      line_items: [
        LineItem.make!(:tuition, amount: 48000),
        LineItem.make!(amount: 3000),
        LineItem.make!(amount: 750)
      ]
    })
  }

  let(:invoices) do
    [
      Invoice.make!({
        student_id: student[0].id,
        user_id: user.id,
        parent_id: parent[0].id,
        invoice_status_id:  invoice_status_1.id,
        school_year: Time.current.year + 543,
        semester: "1",
        grade_name: "Kindergarten 1",
        student_name: "สมศรี ใบเสร็จ",
        classroom: "1A",
        line_items: [
          LineItem.make!(:tuition, amount: 58000),
        ]
      }),
      Invoice.make!({
        student_id: student[0].id,
        user_id: user.id,
        parent_id: parent[0].id,
        invoice_status_id:  invoice_status_1.id,
        school_year: Time.current.year + 543,
        semester: "2",
        grade_name: "Kindergarten 1",
        student_name: "สมศรี ใบเสร็จ",
        classroom: "1B",
        line_items: [
          LineItem.make!(:tuition, amount: 48000),
          LineItem.make!(amount: 750)
        ]
      }),
      Invoice.make!({
        student_id: student[0].id,
        user_id: user.id,
        parent_id: parent[0].id,
        invoice_status_id:  invoice_status_1.id,
        school_year: Time.current.year + 543 + 1,
        semester: "1",
        grade_name: "Kindergarten 2",
        student_name: "สมศรี ใบเสร็จ",
        classroom: "2A",
        line_items: [
          LineItem.make!(:tuition, amount: 48000),
          LineItem.make!(amount: 41000),
        ]
      }),
      Invoice.make!({
        student_id: student[0].id,
        user_id: user.id,
        parent_id: parent[0].id,
        invoice_status_id:  invoice_status_2.id,
        school_year: Time.current.year + 543 + 1,
        semester: "2",
        grade_name: "Kindergarten 2",
        student_name: "สมศรี ใบเสร็จ",
        classroom: "2B",
        line_items: [
          LineItem.make!(:tuition, amount: 48000),
          LineItem.make!(amount: 3000),
          LineItem.make!(amount: 750),
          LineItem.make!(amount: 100750)
        ]
      })
    ]
  end

  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    classrooms
    studentsparent
    invoice_status_1
    invoice_status_2
    invoice
    gender
  end

  it 'should access to student page' do
    visit '/students#/'
    sleep(1)
    eventually { expect(page).to have_content("นักเรียน") }
  end

  it 'should remove student' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openDeletedStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการลบนักเรียนคนนี้ใช่หรือไม่?") }
    find("a", text: "ตกลง").click
    sleep(1)

    student[0].reload
    eventually { expect(page).to_not have_content ("สมศรี") }
    eventually { expect(student[0].deleted_at.blank?).to be_falsey }
  end

  it 'should resign student' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openResignStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ('คุณต้องการเปลี่ยนสถานะนักเรียนคนนี้เป็น "ลาออก" ใช่หรือไม่?') }
    find("a", text: "ตกลง").click
    sleep(1)

    student[0].reload
    eventually { expect(page).to_not have_content ("สมศรี") }
    eventually { expect(student[0].deleted_at.blank?).to be_falsey }

    qry_alumni = Alumni.where(student_id: student[0].id)
    alumni = qry_alumni.first
    eventually { expect(qry_alumni.count).to eq 1 }
    eventually { expect(alumni.status).to eq "ลาออก" }
  end

  it 'should graduate student' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openGraduateStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ('คุณต้องการเปลี่ยนสถานะนักเรียนคนนี้เป็น "จบการศึกษา" ใช่หรือไม่?') }
    find("a", text: "ตกลง").click
    sleep(1)

    student[0].reload
    eventually { expect(page).to_not have_content ("สมศรี") }
    eventually { expect(student[0].deleted_at.blank?).to be_falsey }

    qry_alumni = Alumni.where(student_id: student[0].id)
    alumni = qry_alumni.first
    eventually { expect(qry_alumni.count).to eq 1 }
    eventually { expect(alumni.status).to eq "จบการศึกษา" }
  end

  it 'should search and change page to other student' do
    student_more
    visit "/students/#{student[0].id}/edit#/"
    sleep(1)
    first('.fa.fa-search').click
    sleep(1)
    all('.search-autocomplete')[3].click
    sleep(1)
    eventually { expect(page).to have_content ("แฟรงค์ คลาวด์") }
  end

  it 'should warning if change page while student data changed and submit' do
    student_more
    visit "/students/#{student_more[1].id}/edit#/"
    sleep(1)
    fill_in 'ชื่อ-นามสกุล', :with => 'นักเรียนชื่อใหม่'
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

  it 'should warning if change page while student data changed and cancel' do
    student_more
    visit "/students/#{student_more[1].id}/edit#/"
    sleep(1)
    fill_in 'ชื่อ-นามสกุล', :with => 'นักเรียนชื่อใหม่'
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

  it 'should warning if click cancel while student data changed and go' do
    student_more
    visit "/students/#{student_more[1].id}/edit#/"
    sleep(1)
    fill_in 'ชื่อ-นามสกุล', :with => 'นักเรียนชื่อใหม่'
    sleep(1)
    first('a', text: "ยกเลิก").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?") }
    sleep(1)
    find("#force-change-page").click
    sleep(1)
    eventually { expect(page).to have_content ("นักเรียน") }
    eventually { expect(page).to have_content ("พิมพ์รายชื่อ") }
  end

  it 'should warning if click cancel while student data changed and cancel' do
    student_more
    visit "/students/#{student_more[1].id}/edit#/"
    sleep(1)
    fill_in 'ชื่อ-นามสกุล', :with => 'นักเรียนชื่อใหม่'
    sleep(1)
    first('a', text: "ยกเลิก").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?") }
    click_button("ยกเลิก")
    sleep(1)
    eventually { expect(page).to have_content ("เรน โบว์") }
  end

  it 'should warning if change page while parent data changed' do
    student_more
    visit "/students/#{student[0].id}/edit#/"
    sleep(1)
    find('#mobile0').set("080-000000")
    sleep(1)
    first('.fa.fa-search').click
    sleep(1)
    first('.search-autocomplete').click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?") }
  end

  it 'should see student on invoice slip, although student deleted' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openDeletedStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการลบนักเรียนคนนี้ใช่หรือไม่?") }
    find("a", text: "ตกลง").click
    sleep(1)

    visit "/invoices/#{invoice.id}/slip.pdf?show_as_html=true"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see student on invoice slip, although student resigned' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openResignStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ('คุณต้องการเปลี่ยนสถานะนักเรียนคนนี้เป็น "ลาออก" ใช่หรือไม่?') }
    find("a", text: "ตกลง").click
    sleep(1)

    visit "/invoices/#{invoice.id}/slip.pdf?show_as_html=true"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see student on invoice slip, although student graduated' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openGraduateStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ('คุณต้องการเปลี่ยนสถานะนักเรียนคนนี้เป็น "จบการศึกษา" ใช่หรือไม่?') }
    find("a", text: "ตกลง").click
    sleep(1)

    visit "/invoices/#{invoice.id}/slip.pdf?show_as_html=true"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see student on invoice_report, although student deleted' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openDeletedStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการลบนักเรียนคนนี้ใช่หรือไม่?") }
    find("a", text: "ตกลง").click
    sleep(1)

    visit '/somsri_invoice#/invoice_report'
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see student on invoice_report, although student resigned' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openResignStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ('คุณต้องการเปลี่ยนสถานะนักเรียนคนนี้เป็น "ลาออก" ใช่หรือไม่?') }
    find("a", text: "ตกลง").click
    sleep(1)

    visit '/somsri_invoice#/invoice_report'
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see student on invoice_report, although student graduated' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openGraduateStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ('คุณต้องการเปลี่ยนสถานะนักเรียนคนนี้เป็น "จบการศึกษา" ใช่หรือไม่?') }
    find("a", text: "ตกลง").click
    sleep(1)

    visit '/somsri_invoice#/invoice_report'
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see student on student_report, although student deleted' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openDeletedStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ("คุณต้องการลบนักเรียนคนนี้ใช่หรือไม่?") }
    find("a", text: "ตกลง").click
    sleep(1)
    visit "/somsri_invoice#/student_report"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see student on student_report, although student resigned' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openResignStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ('คุณต้องการเปลี่ยนสถานะนักเรียนคนนี้เป็น "ลาออก" ใช่หรือไม่?') }
    find("a", text: "ตกลง").click
    sleep(1)
    visit "/somsri_invoice#/student_report"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should see student on student_report, although student graduated' do
    visit "/students"
    sleep(1)
    find("#options#{student[0].id}").click
    first("a[onclick=\"openGraduateStudentModal(#{student[0].id})\"]").click
    sleep(1)
    eventually { expect(page).to have_content ('คุณต้องการเปลี่ยนสถานะนักเรียนคนนี้เป็น "จบการศึกษา" ใช่หรือไม่?') }
    find("a", text: "ตกลง").click
    sleep(1)
    visit "/somsri_invoice#/student_report"
    sleep(1)
    eventually { expect(page).to have_content ("สมศรี") }
  end

  it 'should create student with list' do
    visit '/students/new#/'
    sleep(1)
    full_name = I18n.t('activerecord.attributes.student.full_name')
    nick_name = I18n.t('activerecord.attributes.student.nickname')
    full_name_english = I18n.t('activerecord.attributes.student.full_name_english')
    nickname_english = I18n.t('activerecord.attributes.student.nickname_english')

    page.fill_in full_name, :with => 'นักเรียนเพิ่มใหม่'
    page.fill_in nick_name, :with => 'ใหม่'
    page.fill_in full_name_english, :with => 'Nakreanpermmai'
    page.fill_in nickname_english, :with => 'Mai'
    page.find("#student_classroom_id").select(classrooms[0].name)
    sleep(1)
    click_button("บันทึก")
    sleep(1)
    new_student = Student.where(full_name: "นักเรียนเพิ่มใหม่").first
    eventually { expect(new_student.student_lists.size).to eq(1) }
    eventually { expect(new_student.student_lists[0].list.name).to eq(classrooms[0].name) }
  end

  it 'should warning when create student with blank name' do
    visit '/students/new#/'
    sleep(1)
    page.find("#student_classroom_id").select(classrooms[0].name)
    sleep(1)
    click_button("บันทึก")
    sleep(1)
    new_student = Student.where(full_name: "นักเรียนเพิ่มใหม่").first
    expect(new_student.blank?).to eq true
    expect(page).to have_content(I18n.t('student_info_cannot_save'))
  end

  it 'should create student and gender when locale=th' do
    visit '/students/new#/'
    find('#student_full_name').set("นักเรียน สมศรี")
    page.select 'หญิง', :from => 'student_gender_id'
    sleep(1)
    click_button("บันทึก")
    sleep(1)
    expect(page).to have_content('หญิง')
  end  

  it 'should create student and gender when locale=en' do
    visit '/students/new/?locale=en#'
    find('#student_full_name').set("นักเรียน สมศรี")
    page.select 'Female', :from => 'student_gender_id'
    click_button("Save")
    find("#navbarDropdownMenuLink").click
    find('.fa-commenting-o').hover
    find("a", :text => "English").click
    sleep(1)
    expect(page).to have_content('Female')
  end   

  it 'should create list when add classroom to student' do
    visit "/students/#{student[0].id}/edit#/"
    sleep(1)
    page.find("#student_classroom_id").select(classrooms[0].name)
    sleep(1)
    click_button("บันทึก")
    sleep(1)

    new_student = Student.where(id: student[0].id).first
    eventually { expect(new_student.student_lists.length).to eq(1) }
    eventually { expect(new_student.student_lists[0].list.name).to eq(classrooms[0].name) }
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

  it 'should edit gender student when locale=th' do
    visit "/students/#{student[0].id}/edit#/"
    page.select 'ชาย', :from => 'student_gender_id'
    sleep(1)
    click_button("บันทึก")
    sleep(1)
    expect(page).to have_content('ชาย')
  end

  it 'should edit gender student when locale=en' do
    visit "/students/#{student[0].id}/edit/?locale=en#"
    page.select 'Male', :from => 'student_gender_id'
    click_button("Save")
    sleep(1)
    find("#navbarDropdownMenuLink").click
    find('.fa-commenting-o').hover
    find("a", :text => "English").click
    sleep(1)
    expect(page).to have_content('Male')
  end

  it 'should disable parent\'s mobile and relationship when not select parent' do
    visit "/students/#{student_more[0].id}/edit#/"
    sleep(1)
    find("#parent-link").click
    sleep(1)
    eventually { expect(find('#mobile0')[:disabled]).to eq true }
    eventually { expect(find('#relationship0')[:disabled]).to eq true }
    eventually { expect(find('#mobile1')[:disabled]).to eq true }
    eventually { expect(find('#relationship1')[:disabled]).to eq true }
  end

  it 'should create student' do
    visit "/parents/new#/"
    sleep(1)
    page.fill_in 'ชื่อ-นามสกุล', :with => 'มานี มีตา'
    click_on('บันทึก')
    sleep(1)
    eventually { expect(Parent.where(full_name: 'มานี มีตา').count).to eq 1 }
  end

  it 'should edit student' do
    visit "/parents/#{parent[0].id}/edit#/"
    sleep(1)
    page.fill_in 'ชื่อ-นามสกุล', :with => 'มานี มีตา'
    click_on('บันทึก')
    sleep(1)
    eventually { expect(Parent.where(full_name: 'มานี มีตา').count).to eq 1 }
  end

  it 'should display print student list button' do
    visit "/students#"
    sleep(1)
    eventually { expect(page).to have_content("พิมพ์รายชื่อ") }
    find("#print-student-list").click()
    sleep(1)
    eventually { expect(page).to have_content("แสดงรูป") }
    eventually { expect(page).to have_content("ไม่แสดงรูป") }
  end

  it 'should display all student\'s invoices' do
    invoices
    visit "/students/#{student[0].id}/edit#/"
    click_link('ข้อมูลใบเสร็จ')
    eventually { expect(page).to have_content("51,750.00") }

    eventually { expect(page).to have_content("Kindergarten 1 (1A)") }
    eventually { expect(page).to have_content("58,000.00") }

    eventually { expect(page).to have_content("Kindergarten 1 (1B)") }
    eventually { expect(page).to have_content("48,750.00") }

    eventually { expect(page).to have_content("Kindergarten 2 (2A)") }
    eventually { expect(page).to have_content("89,000.00") }

    eventually { expect(page).to_not have_content("Kindergarten 2 (2B)") }
    eventually { expect(page).to_not have_content("152,500.00") }
  end

  it 'should traslate table page parents when locale=th' do
    visit "/parents#/"
    sleep(1)
    find('input[placeholder="ค้นหา"]').set("หาผู้ปกครองไม่เจอหรอก")
    eventually { expect(page).to have_content("ไม่พบรายการที่ค้นหา !") }
  end

  it 'should traslate table page parents when locale=en' do
    visit "/parents#/"
    sleep(1)
    find("#navbarDropdownMenuLink").click
    find('.fa-commenting-o').hover
    find("a", :text => "English").click
    sleep(1)
    find('input[placeholder="Search"]').set("หาผู้ปกครองไม่เจอหรอก")
    eventually { expect(page).to have_content("No matching records found") }
  end

  it 'should traslate table page students when locale=th' do
    visit "/students#/"
    sleep(1)
    find('input[placeholder="ค้นหา"]').set("หานักเรียนไม่เจอหรอก")
    eventually { expect(page).to have_content("ไม่พบรายการที่ค้นหา !") }
  end

  it 'should traslate table page students when locale=en' do
    visit "/students#/"
    sleep(1)
    find("#navbarDropdownMenuLink").click
    find('.fa-commenting-o').hover
    find("a", :text => "English").click
    sleep(1)
    find('input[placeholder="Search"]').set("หานักเรียนไม่เจอหรอก")
    eventually { expect(page).to have_content("No matching records found") }
  end
end
