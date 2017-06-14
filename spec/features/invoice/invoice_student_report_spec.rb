describe 'Student Report', js: true do
  let(:school_setting) do
    user = SchoolSetting.create!({
      school_year: "2560",
      semesters: "1,2,3",
      current_semester: "1"
    })
  end

  let(:user) { user = User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:invoice_status_1) { InvoiceStatus.make! name: 'Active' }
  let(:invoice_status_2) { InvoiceStatus.make! name: 'Canceled' }

  let(:grades) do
    [
      Grade.make!( name: "Preschool" ),
      Grade.make!( name: "Kindergarten 1" ),
      Grade.make!( name: "Kindergarten 2" ),
      Grade.make!( name: "Kindergarten 3" ),
    ]
  end

  let(:students) do
    [
      Student.make!(student_number: 1, first_name: 'สมศรี' ),
      Student.make!(student_number: 2, first_name: 'มั่งมี', last_name: 'ศรีสุข', nickname: 'รวย', classroom_number: 13 ),
      Student.make!(student_number: 3, first_name: 'มั่งมี3', grade_id: grades[0].id ),
      Student.make!(student_number: 4, first_name: 'มั่งมี4', grade_id: grades[1].id ),
      Student.make!(student_number: 5,first_name: 'มั่งมี5', grade_id: grades[2].id),
      Student.make!(student_number: 6,first_name: 'มั่งมี6', grade_id: grades[3].id),
      Student.make!(first_name: 'มั่งมี7'),
      Student.make!(first_name: 'มั่งมี8'),
      Student.make!(first_name: 'มั่งมี9'),
      Student.make!(first_name: 'มั่งมี10'),
      Student.make!(first_name: 'มั่งมี11')
    ]
  end

  let(:invoices) do
    [
      Invoice.make!(
        student_id: students[0].id, 
        invoice_status_id: invoice_status_1.id,
        line_items: [
          LineItem.make!(:tuition, amount: 48000),
          LineItem.make!(amount: 3000),
          LineItem.make!(amount: 750)
        ]),
      Invoice.make!(
        student_id: students[1].id, 
        invoice_status_id: invoice_status_1.id,
        line_items: [
          LineItem.make!(:tuition),
          LineItem.make!(amount: 10000),
        ]),
    ]
  end

  let(:payment_method) do
    PaymentMethod.create!({
      payment_method:'เงินสด',
      invoice_id: invoices[1].id
    })
  end

  before do
      user.add_role :admin
      login_as(user, scope: :user)
      payment_method
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
      expect(page).to have_content("ยังไม่ได้ชำระ")
    end

    it 'should show paid student on report' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("สมศรี")
      expect(page).to have_content("เงินสด")
      expect(page).to have_content("ชำระแล้ว")
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

    it 'can sort by grade Preschool' do
      #สามารถเลือกดูตามระดับชั้นเรียนได้
      visit 'somsri_invoice#/student_report'
      sleep(2)
      find('#grade-list').click
      click_on("Preschool")
      sleep(1)
      expect(page).to have_content("Preschool", count: 2)
    end

    it 'can sort by grade Preschool and sort by unpaid' do
      #สามารถเลือกดูตามระดับชั้นเรียนได้
      visit 'somsri_invoice#/student_report'
      sleep(2)
      find('#grade-list').click
      click_on("Preschool")
      sleep(1)
      find('div.unused_for_print.col-md-12 > div > div:nth-child(1) > div > div:nth-child(3)').click
      click_on("ยังไม่ได้ชำระ")
      sleep(1)
      expect(page).to have_content("ยังไม่ได้ชำระ", count: 2)
    end

    it 'can sort by grade Kindergarten 1' do
      #สามารถเลือกดูตามระดับชั้นเรียนได้
      visit 'somsri_invoice#/student_report'
      sleep(2)
      find('#grade-list').click
      click_on("Kindergarten 1")
      sleep(1)
      expect(page).to have_content("Kindergarten 1", count: 2)
    end

    it 'can sort by grade Kindergarten 1 and unpaid' do
      #สามารถเลือกดูตามระดับชั้นเรียนได้
      visit 'somsri_invoice#/student_report'
      sleep(2)
      find('#grade-list').click
      click_on("Kindergarten 1")
      sleep(1)
      find('div.unused_for_print.col-md-12 > div > div:nth-child(1) > div > div:nth-child(3)').click
      click_on("ยังไม่ได้ชำระ")
      sleep(1)
      expect(page).to have_content("ยังไม่ได้ชำระ", count: 2)
    end

    it 'can sort by grade Kindergarten 2' do
      #สามารถเลือกดูตามระดับชั้นเรียนได้
      visit 'somsri_invoice#/student_report'
      sleep(2)
      find('#grade-list').click
      click_on("Kindergarten 2")
      sleep(1)
      expect(page).to have_content("Kindergarten 2", count: 2)
    end

    it 'can sort by grade Kindergarten 2 and unpaid' do
      #สามารถเลือกดูตามระดับชั้นเรียนได้
      visit 'somsri_invoice#/student_report'
      sleep(2)
      find('#grade-list').click
      click_on("Kindergarten 2")
      sleep(1)
      find('div.unused_for_print.col-md-12 > div > div:nth-child(1) > div > div:nth-child(3)').click
      click_on("ยังไม่ได้ชำระ")
      sleep(1)
      expect(page).to have_content("ยังไม่ได้ชำระ", count: 2)    
    end

    it 'can sort by grade Kindergarten 3' do
      #สามารถเลือกดูตามระดับชั้นเรียนได้
      visit 'somsri_invoice#/student_report'
      sleep(2)
      find('#grade-list').click
      click_on("Kindergarten 3")
      sleep(1)
      expect(page).to have_content("Kindergarten 3")
    end

    it 'can sort by grade Kindergarten 3 and unpaid' do
      #สามารถเลือกดูตามระดับชั้นเรียนได้
      visit 'somsri_invoice#/student_report'
      sleep(2)
      find('#grade-list').click
      click_on("Kindergarten 3")
      sleep(1)
      find('div.unused_for_print.col-md-12 > div > div:nth-child(1) > div > div:nth-child(3)').click
      click_on("ยังไม่ได้ชำระ")
      sleep(1)
      expect(page).to have_content("ยังไม่ได้ชำระ", count: 2)    
    end

    it 'display tuition fee' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("48,000.00")
    end

    it 'display total of total fee(of all student)' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("109,750.00")
    end

    it 'display total other fee' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("13,750.00")
    end

    it 'display total tuition fee' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("96,000.00")
    end

    it 'should display 10 row per page' do
      visit 'somsri_invoice#/student_report'
      sleep(5)
      expect(page).to have_selector("tr.ng-scope", count: 10)
      expect(page).to have_content("First Previous 12 Next Last")
      expect(page).to have_content("96,000.00 13,750.00 109,750.00")
    end

    it 'should display page 2' do
      visit 'somsri_invoice#/student_report'
      sleep(5)
      all('li.pagination-page.ng-scope a').last.click
      sleep(5)
      expect(page).to have_selector("tr.ng-scope", count: 1)
      expect(page).to have_content("First Previous 12 Next Last")
      expect(page).to have_content("96,000.00 13,750.00 109,750.00")
    end

    it 'display only active invoice' do
      visit 'somsri_invoice#/student_report'
      sleep(1)
      expect(page).to have_content("มั่งมี ศรีสุข รวย 13 ชำระแล้ว เงินสด 48,000.00 10,000.00 58,000.00")
    end
  end

end


