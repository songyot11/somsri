describe 'Invoice-Report', js: true do

  let(:user) { user = User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:grade){grade = Grade.create(
    name: "Kindergarten 1"
  )}

  let(:invoice_status_1) { InvoiceStatus.make! name: 'Active' }
  let(:invoice_status_2) { InvoiceStatus.make! name: 'Canceled' }

  let(:students) do
    [
      student1 = Student.make!({
        first_name: 'มั่งมี',
        last_name: 'ศรีสุข',
        nickname: 'รวย' ,
        gender_id: 1 ,
        grade_id: 2 ,
        classroom: '1A' ,
        classroom_number: 13 ,
        student_number: 23 ,

      }),
      student2 = Student.make!({
        first_name: 'สมศรี',
        last_name: 'ณ บานาน่าโค๊ดดิ้ง',
        nickname: 'กล้วย' ,
        gender_id: 2 ,
        grade_id: 4 ,
        classroom: '1A' ,
        classroom_number: 14 ,
        student_number: 22 ,
        birthdate: Time.now

      }),
      student3 = Student.make!({
        first_name: 'สมศรี',
        last_name: 'ณ บานาน่าโค๊ดดิ้ง',
        nickname: 'กั้ง' ,
        gender_id: 2 ,
        grade_id: 4 ,
        classroom: '1A' ,
        classroom_number: 14 ,
        student_number: 21 ,
        birthdate: Time.now

      })
    ]
  end

  let(:student4){student4 = Student.create!(
    full_name: 'สมพล 1' ,
    nickname: 'กั้ง' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 100 ,
    student_number: 9001 ,
    birthdate: Time.now
  )}

  let(:student5){student5 = Student.create!(
    full_name: 'สมพล 2' ,
    nickname: 'กั้ง' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 102 ,
    student_number: 9002 ,
    birthdate: Time.now
  )}

  let(:student6){student6 = Student.create!(
    full_name: 'สมพล 3' ,
    nickname: 'กั้ง' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 103 ,
    student_number: 9003 ,
    birthdate: Time.now
  )}

  let(:student7){student7 = Student.create!(
    full_name: 'สมพล 4' ,
    nickname: 'กั้ง' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 104 ,
    student_number: 9004 ,
    birthdate: Time.now
  )}

  let(:student8){student8 = Student.create!(
    full_name: 'สมพล 5' ,
    nickname: 'กั้ง' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 105 ,
    student_number: 9005 ,
    birthdate: Time.now
  )}

  let(:student9){student9 = Student.create!(
    full_name: 'สมพล 6' ,
    nickname: 'กั้ง' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 106 ,
    student_number: 9006 ,
    birthdate: Time.now
  )}

  let(:student10){student10 = Student.create!(
    full_name: 'สมพล 7' ,
    nickname: 'กั้ง' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 107 ,
    student_number: 9007 ,
    birthdate: Time.now
  )}

  let(:student11){student11 = Student.create!(
    full_name: 'สมพล 8' ,
    nickname: 'กั้ง' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 108 ,
    student_number: 9008 ,
    birthdate: Time.now
  )}

  let(:invoice) do
    [
      invoice1 = Invoice.make!({
        student_id: students[0].id,
        invoice_status_id:  invoice_status_1.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition, amount: 48000),
          LineItem.make!(amount: 3000),
          LineItem.make!(amount: 750)
        ]
      }),
      invoice2 = Invoice.make!({
        student_id: students[1].id,
        invoice_status_id: invoice_status_2.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]
      }),
      invoice3 = Invoice.make!({
        student_id: students[2].id,
        invoice_status_id: invoice_status_1.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]
      }),
      payment_method1 = PaymentMethod.create!({
        payment_method:'เงินสด',
        invoice_id: invoice1.id
      })
    ]
  end

  let(:invoice_for_paginate) do
    [
      invoice4 = Invoice.make!({
        student_id: student4.id,
        invoice_status_id: invoice_status_1.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]
      }),
      invoice5 = Invoice.make!({
        student_id: student5.id,
        invoice_status_id: invoice_status_1.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]
      }),
      invoice6 = Invoice.make!({
        student_id: student6.id,
        invoice_status_id: invoice_status_1.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]
      }),
      invoice7 = Invoice.make!({
        student_id: student7.id,
        invoice_status_id: invoice_status_1.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]
      }),
      invoice8 = Invoice.make!({
        student_id: student8.id,
        invoice_status_id: invoice_status_1.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]
      }),
      invoice9 = Invoice.make!({
        student_id: student9.id,
        invoice_status_id: invoice_status_1.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]
      }),
      invoice10 = Invoice.make!({
        student_id: student10.id,
        invoice_status_id: invoice_status_1.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]
      }),
      invoice11 = Invoice.make!({
        student_id: student11.id,
        invoice_status_id: invoice_status_1.id,
        school_year: "2560",
        semester: "1",
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]
      })
    ]
  end

  before do
    user.add_role :admin
    login_as(user, scope: :user)
    grade
    invoice
  end

  describe 'Student invoice report' do
    it 'should show report page' do
      visit 'somsri_invoice#/report'
      sleep(1)
      expect(page).to have_content("รายงานค่าเทอม")
      expect(page).to have_content("รายงานประจำวัน")
    end

    it 'should show student report page' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content "รหัส"
    end

    it 'should show unpaid student on report' do
      #แสดงนักเรียนที่ยังไมไ่ด้ชำระเงิน
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("มั่งมี")
      expect(page).to have_content("ยกเลิก")
    end

    it 'should show paid student on report' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("สมศรี")
      expect(page).to have_content("เงินสด")
      expect(page).to have_content("ชำระแล้ว")
    end

    it 'can sort by grade' do
      #สามารถเลือกดูตามระดับชั้นเรียนได้
      visit 'somsri_invoice#/student_report'
      sleep(1)
      find('#grade-list').click
      sleep(1)
      click_on("Kindergarten 1")
      expect(page).to have_content("มั่งมี")
    end

    it 'display total fee' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("51,750.00")
    end

    it 'display other fee' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("3,750.00")
    end

    it 'can sort by grade' do
      #สามารถเลือกดูตามระดับชั้นเรียนได้
      visit 'somsri_invoice#/student_report'
      sleep(1)
      find('#grade-list').click
      sleep(1)
      click_on("Kindergarten 1")
      expect(page).to have_content("Kindergarten 1")
    end

    it 'display tuition fee' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("48,000.00")
    end

    it 'display total of total fee(of all student)' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("167,750.00")
    end

    it 'display total other fee' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("23,750.00")
    end

    it 'display total tuition fee' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("144,000.00")
    end

    it 'should display 10 row per page' do
      invoice_for_paginate
      visit 'somsri_invoice#/student_report'
      sleep(5)
      expect(page).to have_selector("tr.ng-scope", count: 10)
      expect(page).to have_content("First Previous 12 Next Last")
      expect(page).to have_content("28,000.00 103,750.00 631,750.00")
    end

    it 'should display page 2' do
      invoice_for_paginate
      visit 'somsri_invoice#/student_report'
      sleep(5)
      all('li.pagination-page.ng-scope a').last.click
      sleep(5)
      expect(page).to have_selector("tr.ng-scope", count: 1)
      expect(page).to have_content("First Previous 12 Next Last")
      expect(page).to have_content("28,000.00 103,750.00 631,750.00")
    end
  end

  describe 'Invoice report' do
    it 'should display 10 row per page' do
      invoice_for_paginate
      visit 'somsri_invoice#/invoice_report'
      sleep(5)
      expect(page).to have_selector("tr.ng-scope", count: 10)
      expect(page).to have_content("First Previous 12 Next Last")
    end

    it 'should display page 2' do
      invoice_for_paginate
      visit 'somsri_invoice#/invoice_report'
      sleep(5)
      all('li.pagination-page.ng-scope a').last.click
      sleep(5)
      expect(page).to have_selector("tr.ng-scope", count: 1)
      expect(page).to have_content("First Previous 12 Next Last")
    end
  end
end
