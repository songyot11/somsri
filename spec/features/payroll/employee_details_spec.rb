describe 'Employee Details', js: true do
  let(:taxrates) do
    [
      Taxrate.make!({order_id: "1", income: "5000000", tax: "0.35"}),
      Taxrate.make!({order_id: "2", income: "2000000", tax: "0.30"}),
      Taxrate.make!({order_id: "3", income: "1000000", tax: "0.25"}),
      Taxrate.make!({order_id: "4", income: "750000", tax: "0.20"}),
      Taxrate.make!({order_id: "5", income: "500000", tax: "0.15"}),
      Taxrate.make!({order_id: "6", income: "300000", tax: "0.10"}),
      Taxrate.make!({order_id: "7", income: "150000", tax: "0.05"})
    ]
  end

  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }

  let(:user) { User.make!({ school_id: school.id }) }

  let(:employees) do
    [
      Employee.make!({
        school_id: school.id,
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
        school_id: school.id,
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
        effective_date: DateTime.now.next_month(1).utc
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 20000,
        tax: 1000,
        position_allowance: 10000,
        fee_etc: 200,
        effective_date: DateTime.now.next_month(1).utc
      }),

      Payroll.make!({
        employee_id: employees[0].id,
        salary: 5000,
        tax: 10,
        advance_payment: 200,
        allowance: 300,
        effective_date: DateTime.now.utc
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 2000,
        tax: 100,
        position_allowance: 1000,
        fee_etc: 20,
        effective_date: DateTime.now.utc
      }),

      Payroll.make!({
        employee_id: employees[0].id,
        salary: 500,
        tax: 1,
        advance_payment: 20,
        allowance: 30,
        effective_date: DateTime.new(2016, 8, 1).utc
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 200,
        tax: 10,
        position_allowance: 100,
        fee_etc: 2,
        effective_date: DateTime.new(2016, 8, 1).utc
      })
    ]
  end

  before do
    user.add_role :admin
    taxrates
    payrolls
    login_as(user, scope: :user)
  end

  describe 'employees list screen' do
    it 'should goto employee details when click employee' do
      visit "/somsri_payroll#/employees"
      sleep(1)
      first('.card').click
      sleep(1)
      eventually { expect(page).to have_css('div.employee-details') }
    end
  end

  describe 'employee detail screen' do
    before :each do
      visit "/somsri_payroll#/employees/#{employees[0].id}"
      sleep(1)
    end

    it 'should diplay lastest employee details' do
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      eventually { expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน').value).to eq '50000' }
      # expect(find_field('ภาษี').value.to_i).to be > 0
      eventually { expect(find_field('เบิกล่วงหน้า').value).to eq '2000' }
      eventually { expect(find_field('ค่ากะ / ค่าเบี้ยเลี้ยง').value).to eq '3000' }
      # expect(page).to have_content('เงินเดือนสุทธิ 50900')
    end

    it 'should diplay total pay depend on payroll change' do
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      page.fill_in 'ค่าแรง / เงินเดือนปัจจุบัน', :with => '2000000'
      page.fill_in 'เงินสอนพิเศษ', :with => '500000'
      page.fill_in 'ค่าตำแหน่ง', :with => '70000'
      # page.fill_in 'เงินสะสมเข้ากองทุนสงเคราะห์', :with => '40000'
      page.fill_in 'ค่ากะ / ค่าเบี้ยเลี้ยง', :with => '5000'
      page.fill_in 'ขาดงาน', :with => '1000'
      page.fill_in 'เบี้ยขยัน', :with => '500'
      page.fill_in 'โบนัส', :with => '90'
      page.fill_in 'เบิกล่วงหน้า', :with => '30'
      page.fill_in 'รายได้อื่นๆ', :with => '9'
      page.fill_in 'หักอื่นๆ', :with => '2'
      # page.fill_in 'ภาษี', :with => '1000000'
      # page.fill_in 'ประกันสังคม', :with => '300000'
      sleep(1)
      eventually { expect(page).to have_content('เงินเดือนสุทธิ ') }
    end

    it 'should diplay confirmation modal when change detail and click ยกเลิก' do
      page.fill_in 'First Name', :with => 'Eve'
      click_link('เงินเดือน')
      sleep(1)
      page.fill_in 'โบนัส', :with => 99999999
      sleep(1)
      click_button('ยกเลิก')
      sleep(1)
      eventually { expect(page).to have_content("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?") }
    end

    it 'should save change and goto employee lists' do
      page.fill_in 'นามสกุล', :with => 'โอชา'
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      page.fill_in 'ค่าแรง / เงินเดือนปัจจุบัน', :with => '200'
      sleep(1)
      click_button('บันทึก')
      sleep(1)
      click_button('ตกลง')
      sleep(1)

      employee = Employee.find(employees[0].id)
      payroll = Payroll.find(payrolls[0].id)

      eventually { expect(employee.last_name_thai).to eq 'โอชา' }
      eventually { expect(employee.salary).to eq 200 }
      eventually { expect(payroll.salary).to eq 200 }
      eventually { expect(page).to have_css('div.employee-details') }
    end

    it 'should diplay histories when select histories dropdown' do
      click_link('เงินเดือน')
      sleep(1)
      find('#month-list').click
      sleep(1)
      find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
      sleep(1)
      eventually { expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน', disabled: false).value.to_i).to be > 0 }
      # expect(find_field('ภาษี', disabled: false).value.to_i).to be > 0
      eventually { expect(find_field('เบิกล่วงหน้า', disabled: false).value.to_i).to be > 0 }
      eventually { expect(find_field('ค่ากะ / ค่าเบี้ยเลี้ยง', disabled: false).value.to_i).to be > 0 }
      eventually { expect(page).to have_content('เงินเดือนสุทธิ ') }
    end

    it 'should not diplay warning modal when select histories dropdown after edit employee detail' do
      sleep(1)
      page.fill_in 'นามสกุล', :with => 'โอชา'
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      find('#month-list').click
      sleep(1)
      find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
      sleep(1)
      eventually { expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน', disabled: false).value.to_i).to be > 0 }
      # expect(find_field('ภาษี', disabled: false).value.to_i).to be > 0
      eventually { expect(find_field('เบิกล่วงหน้า', disabled: false).value.to_i).to be > 0 }
      eventually { expect(find_field('ค่ากะ / ค่าเบี้ยเลี้ยง', disabled: false).value.to_i).to be > 0 }
      eventually { expect(page).to have_content('เงินเดือนสุทธิ ') }
    end

    it 'should diplay warning modal when select histories dropdown after edit payroll' do
      click_link('เงินเดือน')
      sleep(1)
      page.fill_in 'ค่าแรง / เงินเดือนปัจจุบัน', :with => '999'
      sleep(1)
      find('#month-list').click
      sleep(1)
      find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
      sleep(1)
      eventually { expect(page).to have_content("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?") }
    end

    it 'should save only employee data when in histories mode and click บันทึก' do
      page.fill_in 'นามสกุล', :with => 'โอชา'
      click_link('เงินเดือน')
      sleep(1)
      page.fill_in 'ค่าแรง / เงินเดือนปัจจุบัน', :with => '999'
      sleep(1)
      find('#month-list').click
      sleep(1)
      find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
      sleep(1)
      click_button('ตกลง')
      sleep(1)
      click_button('บันทึก')
      sleep(1)
      click_button('ตกลง')
      sleep(1)
      visit "/somsri_payroll#/employees/#{employees[0].id}"
      sleep(1)
      eventually { expect(find_field('นามสกุล').value).to eq 'โอชา' }
      click_link('เงินเดือน')
      sleep(1)
      eventually { expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน').value).to eq '50000' }
    end

    # it 'can edit history data' do
    #   find('#month-list').click
    #   sleep(1)
    #   find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
    #   sleep(1)
    #   page.fill_in 'ค่าแรง / เงินเดือนปัจจุบัน', :with => 1
    #   sleep(1)
    #   click_button('บันทึก')
    #   sleep(1)
    #   click_button('ตกลง')
    #   sleep(1)

    #   # revisit and check the value
    #   visit "/#/employees/#{employees[0].id}"
    #   sleep(1)
    #   # check data in current month
    #   expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน').value).to eq '50000'
    #   find('#month-list').click
    #   sleep(1)
    #   find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
    #   sleep(1)
    #   # check edited data on previous month
    #   expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน').value).to eq '1'
    # end

    # it 'should go to 2016-8 slip' do
    #   find('#month-list').click
    #   sleep(1)
    #   find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
    #   sleep(1)
    #   click_button('พิมพ์ใบจ่ายเงินเดือน')
    #   sleep(1)
    #   expect(page).to have_css("#payroll-slip")
    #   expect(page).to have_content("ส.ค. 59")
    # end

    it 'should edit birthdate' do
      click_link('ข้อมูลส่วนตัว')
      eventually { expect(find('#birthdate').value).to_not have_content '03/12/1990' }

      find('#birthdate').set('03/12/1990')
      sleep(1)
      click_button('บันทึก')
      sleep(1)
      click_button('ตกลง')
      sleep(1)
      employee = Employee.find(employees[0].id)

      visit "/somsri_payroll#/employees/#{employees[0].id}"
      sleep(1)
      click_link('ข้อมูลส่วนตัว')
      eventually { expect(find('#birthdate').value).to have_content '03/12/1990' }
    end

    it 'should edit start_date' do
      eventually { expect(find('#start_date').value).to_not have_content '03/12/1990' }

      find('#start_date').set('03/12/1990')
      sleep(1)
      click_button('บันทึก')
      sleep(1)
      click_button('ตกลง')
      sleep(1)
      employee = Employee.find(employees[0].id)
      visit "/somsri_payroll#/employees/#{employees[0].id}"
      eventually { expect(find('#start_date').value).to have_content '03/12/1990' }
    end

    describe 'employee_type' do
      it 'can edit' do
        sleep(1)
        eventually { expect(page).to have_select('ประเภทการจ้างงาน', selected: 'ลูกจ้างประจำ') }
        select 'ลูกจ้างชั่วคราว', from: 'ประเภทการจ้างงาน'
        click_button('บันทึก')
        sleep(1)
        click_button('ตกลง')
        sleep(1)

        visit "/somsri_payroll#/employees/#{employees[0].id}"
        sleep(1)
        eventually { expect(page).to have_select('ประเภทการจ้างงาน', selected: 'ลูกจ้างชั่วคราว') }
      end
    end

    describe 'insurance flags' do
      it 'can edit' do
        cbx_pvf = find('#pay_pvf')
        cbx_social_insurance = find('#pay_social_insurance')

        eventually { expect(cbx_pvf).to_not be_checked }
        eventually { expect(cbx_social_insurance).to_not be_checked }

        cbx_pvf.click
        cbx_social_insurance.click

        click_button('บันทึก')
        sleep(1)
        click_button('ตกลง')
        sleep(1)

        visit "/somsri_payroll#/employees/#{employees[0].id}"
        sleep(1)

        eventually { expect(cbx_pvf).to be_checked }
        eventually { expect(cbx_social_insurance).to be_checked }
      end
    end
  end
end
