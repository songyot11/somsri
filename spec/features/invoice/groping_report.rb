describe 'Grouping Report', js: true do
  let(:school_setting) do
    SchoolSetting.make!()
  end

  let(:grouping_options) do
    GroupingReportOption.make!( name: "ค่าเทอม", keyword: "Tuition Fee|ค่าเทอม")
    GroupingReportOption.make!( name: "ค่าเสื้อ", keyword: "ค่าเสื้อ|ค่าชุด")
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
      Student.make!(student_number: 1, first_name: 'สมศรี', last_name: 'ศรีสุข'),
      Student.make!(student_number: 2, first_name: 'มั่งมี', last_name: 'ศรีสุข', nickname: 'รวย', classroom_number: 13 ),
      Student.make!(student_number: 3, first_name: 'มั่งมี3', last_name: 'ศรีสุข', grade_id: grades[0].id )
    ]
  end

  let(:invoices) do
    [
      Invoice.make!(
        student_id: students[0].id,
        invoice_status_id: invoice_status_1.id,
        updated_at: DateTime.now,
        line_items: [
          LineItem.make!(:tuition, amount: 100000),
          LineItem.make!(detail: "ค่าเสื้อนักเรียน", amount: 1000),
          LineItem.make!(detail: "ค่าชุดพื้นเมือง", amount: 1000)
        ]),
      Invoice.make!(
        student_id: students[1].id,
        invoice_status_id: invoice_status_1.id,
        updated_at: DateTime.now,
        line_items: [
          LineItem.make!(:tuition, amount: 100000),
          LineItem.make!(detail: "ห้องสมุด", amount: 10000)
        ]),
      Invoice.make!(
        student_id: students[1].id,
        invoice_status_id: invoice_status_1.id,
        updated_at: DateTime.now.yesterday,
        line_items: [
          LineItem.make!(detail: "ห้องสมุด", amount: 10000),
          LineItem.make!(detail: "ค่าชุดพื้นเมือง", amount: 1000)
        ]),
      Invoice.make!(
        student_id: students[1].id,
        invoice_status_id: invoice_status_2.id,
        updated_at: DateTime.now.yesterday,
        line_items: [
          LineItem.make!(detail: "ห้องสมุด", amount: 10000000000),
          LineItem.make!(detail: "ค่าชุดพื้นเมือง", amount: 10000000000)
        ])
    ]
  end

  let(:payment_method) do
    PaymentMethod.create!({ payment_method:'เงินสด', invoice_id: invoices[0].id, amount: 2000.0 })
    PaymentMethod.create!({ payment_method:'บัตรเครดิต', invoice_id: invoices[0].id, amount: 40000.0 })
    PaymentMethod.create!({ payment_method:'เช็คธนาคาร', invoice_id: invoices[0].id, amount: 30000.0 })
    PaymentMethod.create!({ payment_method:'เงินโอน', invoice_id: invoices[0].id, amount: 30000.0 })
    PaymentMethod.create!({ payment_method:'เงินสด', invoice_id: invoices[1].id, amount: 110000.0 })
    PaymentMethod.create!({ payment_method:'เงินสด', invoice_id: invoices[2].id, amount: 11000.0 })
  end

  let(:today_str){ DateTime.now.strftime("%d/%m/%Y") }
  let(:yesterday_str){ DateTime.now.yesterday.strftime("%d/%m/%Y") }

  before do
    grouping_options
    school_setting
    payment_method
    user.add_role :admin
    login_as(user, scope: :user)
  end

  describe 'Grouping report' do
    it 'should display report page' do
      visit '/somsri_invoice#/grouping_report'
      sleep(1)
      expect(page).to have_content("#{yesterday_str} 11,000.00 0.00 0.00 0.00 0.00 1,000.00 10,000.00 11,000.00")
      expect(page).to have_content("#{today_str} 112,000.00 40,000.00 30,000.00 30,000.00 200,000.00 2,000.00 10,000.00 212,000.00")
      expect(page).to have_content("รวมทั้งหมด 123,000.00 40,000.00 30,000.00 30,000.00 200,000.00 3,000.00 20,000.00 223,000.00")
    end

    it 'should display report page only ค่าเสื้อ' do
      visit '/somsri_invoice#/grouping_report'
      sleep(1)
      find('span', text: 'เลือกประเภท').click
      sleep(1)
      find('.dropdown-menu label', text: 'ค่าเทอม').click
      sleep(1)
      expect(page).to have_content("#{yesterday_str} 11,000.00 0.00 0.00 0.00 1,000.00 10,000.00 11,000.00")
      expect(page).to have_content("#{today_str} 112,000.00 40,000.00 30,000.00 30,000.00 2,000.00 210,000.00 212,000.00")
      expect(page).to have_content("รวมทั้งหมด 123,000.00 40,000.00 30,000.00 30,000.00 3,000.00 220,000.00 223,000.00")
    end

    it 'should display report per student by click link' do
      visit '/somsri_invoice#/grouping_report'
      sleep(1)
      first('td:nth-child(1) a').click
      sleep(1)
      expect(page).to have_content("มั่งมี ศรีสุข 11,000.00 0.00 0.00 0.00 0.00 1,000.00 10,000.00 11,000.00")
      expect(page).to have_content(" รวมทั้งหมด 11,000.00 0.00 0.00 0.00 0.00 1,000.00 10,000.00 11,000.00")
    end

    it 'should display report per student by select same date' do
      visit '/somsri_invoice#/grouping_report'
      sleep(1)
      find('#start_date').set(today_str)
      sleep(1)
      expect(page).to have_content("สมศรี ศรีสุข 2,000.00 40,000.00 30,000.00 30,000.00 100,000.00 2,000.00 0.00 102,000.00")
      expect(page).to have_content("มั่งมี ศรีสุข 110,000.00 0.00 0.00 0.00 100,000.00 0.00 10,000.00 110,000.00")
      expect(page).to have_content("รวมทั้งหมด 112,000.00 40,000.00 30,000.00 30,000.00 200,000.00 2,000.00 10,000.00 212,000.00")
    end

    it 'should display report per student by select same date and display only ค่าเสื้อ' do
      visit '/somsri_invoice#/grouping_report'
      sleep(1)
      find('#start_date').set(today_str)
      sleep(1)
      find('span', text: 'เลือกประเภท').click
      sleep(1)
      find('.dropdown-menu label', text: 'ค่าเทอม').click
      sleep(1)
      expect(page).to have_content("สมศรี ศรีสุข 2,000.00 40,000.00 30,000.00 30,000.00 2,000.00 100,000.00 102,000.00")
      expect(page).to have_content("มั่งมี ศรีสุข 110,000.00 0.00 0.00 0.00 0.00 110,000.00 110,000.00")
      expect(page).to have_content("รวมทั้งหมด 112,000.00 40,000.00 30,000.00 30,000.00 2,000.00 210,000.00 212,000.00")
    end

    it 'should qry from pass to yesterday' do
      visit '/somsri_invoice#/grouping_report'
      sleep(1)
      expect(page).to have_content("#{yesterday_str} 11,000.00 0.00 0.00 0.00 0.00 1,000.00 10,000.00 11,000.00")
      expect(page).to have_content("#{today_str} 112,000.00 40,000.00 30,000.00 30,000.00 200,000.00 2,000.00 10,000.00 212,000.00")
      expect(page).to have_content("รวมทั้งหมด 123,000.00 40,000.00 30,000.00 30,000.00 200,000.00 3,000.00 20,000.00 223,000.00")

      find('#start_date').set("")
      sleep(1)
      find('#end_date').set(yesterday_str)

      sleep(1)
      expect(page).to have_content("#{yesterday_str} 11,000.00 0.00 0.00 0.00 0.00 1,000.00 10,000.00 11,000.00")
      expect(page).to have_content("รวมทั้งหมด 11,000.00 0.00 0.00 0.00 0.00 1,000.00 10,000.00 11,000.00")
    end

    it 'should qry from today to present' do
      visit '/somsri_invoice#/grouping_report'
      sleep(1)
      expect(page).to have_content("#{yesterday_str} 11,000.00 0.00 0.00 0.00 0.00 1,000.00 10,000.00 11,000.00")
      expect(page).to have_content("#{today_str} 112,000.00 40,000.00 30,000.00 30,000.00 200,000.00 2,000.00 10,000.00 212,000.00")
      expect(page).to have_content("รวมทั้งหมด 123,000.00 40,000.00 30,000.00 30,000.00 200,000.00 3,000.00 20,000.00 223,000.00")

      find('#start_date').set(today_str)
      sleep(1)
      find('#end_date').set("")

      sleep(1)
      expect(page).to have_content("#{today_str} 112,000.00 40,000.00 30,000.00 30,000.00 200,000.00 2,000.00 10,000.00 212,000.00")
      expect(page).to have_content("รวมทั้งหมด 112,000.00 40,000.00 30,000.00 30,000.00 200,000.00 2,000.00 10,000.00 212,000.00")
    end

    it 'should qry from pass to present' do
      visit '/somsri_invoice#/grouping_report'
      sleep(1)
      find('#start_date').set("")
      sleep(1)
      find('#end_date').set("")

      sleep(1)
      expect(page).to have_content("#{yesterday_str} 11,000.00 0.00 0.00 0.00 0.00 1,000.00 10,000.00 11,000.00")
      expect(page).to have_content("#{today_str} 112,000.00 40,000.00 30,000.00 30,000.00 200,000.00 2,000.00 10,000.00 212,000.00")
      expect(page).to have_content("รวมทั้งหมด 123,000.00 40,000.00 30,000.00 30,000.00 200,000.00 3,000.00 20,000.00 223,000.00")
    end
  end

end
