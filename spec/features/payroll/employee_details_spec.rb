
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

  let(:grade) { Grade.make!(name: 'K1') }

  let(:classrooms) do
    [
      Classroom.make!({name: "1A", grade_id: grade.id}),
      Classroom.make!({name: "1B", grade_id: grade.id})
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
        pay_pvf: true,
        pay_social_insurance: true,
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

  let(:employee_without_payroll) do
    Employee.make!({
      school_id: school.id,
      first_name: "คนใหม่",
      last_name: "เดือนแรกเลย",
      prefix_thai: "นาย",
      salary: 20000
    })
  end

  let(:employee_without_prefix) do
    Employee.make!({
      school_id: school.id,
      first_name_thai: "สมจิตร",
      last_name_thai: "เป็นนักมวย",
      prefix_thai: nil,
      salary: 20000
    })
  end

  let(:payrolls) do
    [
      Payroll.update(employees[0].payrolls[0].id,
      {
        employee_id: employees[0].id,
        salary: 50000,
        advance_payment: 2000,
        allowance: 3000
      }),

      Payroll.update(employees[1].payrolls[0].id,
      {
        employee_id: employees[1].id,
        salary: 20000,
        position_allowance: 10000,
        fee_etc: 200
      }),

      Payroll.make!({
        employee_id: employees[0].id,
        salary: 5000,
        advance_payment: 200,
        allowance: 300,
        closed: true,
        effective_date: DateTime.now.utc
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 2000,
        position_allowance: 1000,
        fee_etc: 20,
        closed: true,
        effective_date: DateTime.now.utc
      }),

      Payroll.make!({
        employee_id: employees[0].id,
        salary: 500,
        advance_payment: 20,
        allowance: 30,
        tax: 9999,
        social_insurance: 999,
        pvf: 99,
        closed: true,
        effective_date: DateTime.new(2016, 8, 1).utc
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 200,
        position_allowance: 100,
        fee_etc: 2,
        closed: true,
        effective_date: DateTime.new(2016, 8, 1).utc
      })
    ]
  end

  before do
    SiteConfig.make!({ student_number_leading_zero: 0 })
    user.add_role :admin
    taxrates
    payrolls
    classrooms
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

    it 'should not diplay employee name without prefix' do
        employee_without_prefix
        visit "/somsri_payroll#/employees/#{employee_without_prefix.id}"
        sleep(1)
        eventually { expect(page).to have_content('3: สมจิตร เป็นนักมวย') }
    end

    it 'should not diplay print slip button' do
      visit "/somsri_payroll#/employees/#{employee_without_payroll.id}"
      sleep(1)
      eventually { expect(page).not_to have_content('พิมพ์ใบจ่ายเงินเดือน') }
    end

    it 'have employees list' do
      sleep(1)
      expect(page).to have_content('สมศรี')
      expect(page).to_not have_content('สมจิตร')

      find('#employeeName').click()
      eventually { expect(page).to have_content('สมศรี') }
      eventually { expect(page).to have_content('สมจิตร') }
    end

    it 'can filter employees list' do
      sleep(1)

      find('#employeeName').click()
      sleep(2)

      eventually { expect(page).to have_content('สมจิตร เป็นนักมวย') }
      
      fill_in 'employeeFilter', with: 'ศรี'
      eventually { expect(page).to_not have_content('สมจิตร เป็นนักมวย') }
    end

    it 'should display lastest employee details' do
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
    end

    it 'should auto calculate tax, pvf and social insurance' do
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      page.fill_in 'ค่าแรง / เงินเดือนปัจจุบัน', :with => '2000000'
      page.fill_in 'เงินสอนพิเศษ', :with => '500000'
      page.fill_in 'ค่าตำแหน่ง', :with => '70000'
      page.fill_in 'ค่ากะ / ค่าเบี้ยเลี้ยง', :with => '5000'
      page.fill_in 'ขาดงาน', :with => '1000'
      page.fill_in 'เบี้ยขยัน', :with => '500'
      page.fill_in 'โบนัส', :with => '90'
      page.fill_in 'เบิกล่วงหน้า', :with => '30'
      page.fill_in 'รายได้อื่นๆ', :with => '9'
      page.fill_in 'หักอื่นๆ', :with => '2'
      sleep(1)
      eventually { expect(find_field('ภาษีเงินได้บุคคลธรรมดา', disabled: true).value.to_i).to eq 855763 }
      eventually { expect(find_field('ประกันสังคม', disabled: true).value.to_i).to eq 750 }
      eventually { expect(find_field('เงินสะสมเข้ากองทุนสงเคราะห์', disabled: true).value.to_i).to eq 60000 }
    end

    it 'should diplay confirmation modal when change detail and click ยกเลิก' do
      sleep(1)
      page.fill_in 'First Name', :with => 'Eve'
      click_link('เงินเดือน')
      sleep(1)
      page.fill_in 'โบนัส', :with => 99999999
      sleep(1)
      click_button('ยกเลิก')
      sleep(1)
      eventually { expect(page).to have_content("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?") }
    end

    it 'should save change and stay still on the current page' do
      page.fill_in 'นามสกุล', :with => 'โอชา'
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      page.fill_in 'ค่าแรง / เงินเดือนปัจจุบัน', :with => '200'

      click_link('ข้อมูลทั่วไป')
      page.find("#grade_id").select("K1")
      page.find("#classroom_id").select(classrooms[0].name)
      sleep(1)

      click_button('บันทึก')
      sleep(1)
      click_button('ตกลง')
      sleep(1)

      employee = Employee.find(employees[0].id)
      payroll = Payroll.find(payrolls[0].id)

      eventually { expect(employee.last_name_thai).to eq 'โอชา' }
      eventually { expect(employee.salary).to eq 200 }
      eventually { expect(employee.classroom).to eq classrooms[0] }
      eventually { expect(employee.grade).to eq grade }
      eventually { expect(payroll.salary).to eq 200 }
      eventually { expect(payroll.note).to eq nil }
      eventually { expect(page).to have_css('div.employee-details') }
    end

    it 'should update employee.salary if changed lasted payroll.salary' do
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      page.fill_in 'ค่าแรง / เงินเดือนปัจจุบัน', :with => '12300'
      click_button('บันทึก')
      sleep(1)
      click_button('ตกลง')
      sleep(1)

      employees[0].reload
      payrolls[0].reload

      eventually { expect(employees[0].salary).to eq 12300 }
      eventually { expect(payrolls[0].salary).to eq 12300 }
    end

    def fill_in_redactor(options)
      if options[:in]
        node = "('#{options[:in]}')"
      else
        node = "('.redactor')"
      end
      page.execute_script( "$#{node}.redactor('set', '#{options[:with]}')" )
    end

    describe "generate attendance list" do

      let(:students) do
        [
          Student.make!({
            first_name: 'มั่งมี',
            last_name: 'ศรีสุข',
            nickname: 'รวย' ,
            gender_id: 1 ,
            grade_id: grade.id,
            classroom: classrooms[0],
            classroom_number: 13 ,
            student_number: 23 ,
          }),
          Student.make!({
            first_name: 'สมศรี',
            last_name: 'ณ บานาน่าโค๊ดดิ้ง',
            nickname: 'กล้วย' ,
            gender_id: 2 ,
            grade_id: grade.id,
            classroom: classrooms[0],
            classroom_number: 14 ,
            student_number: 22 ,
            birthdate: Time.now
          }),
          Student.make!({
            first_name: 'สมศรี',
            last_name: 'ณ บานาน่าโค๊ดดิ้ง',
            nickname: 'กั้ง' ,
            gender_id: 2 ,
            grade_id: grade.id,
            classroom: classrooms[1],
            classroom_number: 14 ,
            student_number: 21 ,
            birthdate: Time.now
          })
        ]
      end

      it 'should generate pin and list' do
        students
        visit "/somsri_payroll#/employees/#{employees[0].id}"
        sleep(1)
        page.find("#classroom_id").select(classrooms[0].name)
        sleep(1)

        click_button('บันทึก')
        sleep(1)
        click_button('ตกลง')
        sleep(1)

        employee = Employee.find(employees[0].id)
        expect(employee.pin).not_to be_nil
        expect(employee.lists.size).to eq(1)
        expect(employee.lists[0].name).to eq("1A")
        expect(employee.lists[0].get_students.size).to eq(2)
        expect(employee.lists[0].get_students.collect(&:student_number)).to include("22")
        eventually { expect(employee.classroom).to eq classrooms[0] }
      end
    end

    it 'should diplay histories with disabled input' do
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      find('#month-list').click
      sleep(1)
      find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
      sleep(1)
      eventually { expect(page).to have_field('ค่าแรง / เงินเดือนปัจจุบัน', disabled: true) }
      eventually { expect(page).to have_field('ขาดงาน', disabled: true) }
      eventually { expect(page).to have_field('เงินสอนพิเศษ', disabled: true) }
      eventually { expect(page).to have_field('สาย', disabled: true) }
      eventually { expect(page).to have_field('ค่าตำแหน่ง', disabled: true) }
      eventually { expect(page).to have_field('ค่ากะ / ค่าเบี้ยเลี้ยง', disabled: true) }
      eventually { expect(page).to have_field('เบี้ยขยัน', disabled: true) }
      eventually { expect(page).to have_field('โบนัส', disabled: true) }
      eventually { expect(page).to have_field('เบิกล่วงหน้า', disabled: true) }
      eventually { expect(page).to have_field('รายได้อื่นๆ', disabled: true) }
      eventually { expect(page).to have_field('หักอื่นๆ', disabled: true) }
      eventually { expect(find('.redactor-editor')['contenteditable']).to eq "false" } #note disable
    end

    it 'should diplay histories with correct calculate total' do
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      eventually { expect(page).to have_content('เงินเดือนสุทธิ 46733.33') }

      find('#month-list').click
      sleep(1)
      find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
      sleep(1)
      eventually { expect(page).to have_content('เงินเดือนสุทธิ -10587.00') }
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
      eventually { expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน', disabled: true).value.to_i).to be > 0 }
      eventually { expect(find_field('เบิกล่วงหน้า', disabled: true).value.to_i).to be > 0 }
      eventually { expect(find_field('ค่ากะ / ค่าเบี้ยเลี้ยง', disabled: true).value.to_i).to be > 0 }
      eventually { expect(page).to have_content('เงินเดือนสุทธิ ') }
    end

    it 'should diplay warning modal when select histories dropdown after edit payroll' do
      sleep(1)
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
      sleep(1)
      page.fill_in 'นามสกุล', :with => 'โอชา'
      sleep(1)
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
      employees[0].reload
      eventually { expect(employees[0].last_name_thai).to eq 'โอชา' }
      closed_payroll = nil
      employees[0].payrolls.each do |payroll|
        closed_payroll = payroll if !payroll.closed
      end
      eventually { expect(closed_payroll.salary).to eq 50000.0 }
    end

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
      sleep(1)
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

    it 'should display current month\'s salary' do
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      find('#month-list').click
      sleep(1)
      find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
      sleep(1)
      eventually { expect(page).to have_field('ค่าแรง / เงินเดือนปัจจุบัน', disabled: true) }
      find('#month-list').click
      sleep(1)
      find('ul.dropdown-menu li a', text: "เดือนปัจจุบัน").click
      sleep(1)
      eventually { expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน').value.to_i).to be 50000 }
    end

    it 'should diplay histories tax, social_insurance and pvf' do
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      find('#month-list').click
      sleep(1)
      find('ul.dropdown-menu li a', text: "สิงหาคม 2559").click
      sleep(1)
      eventually { expect(find_field('ภาษีเงินได้บุคคลธรรมดา', disabled: true).value.to_i).to eq 9999 }
      eventually { expect(find_field('ประกันสังคม', disabled: true).value.to_i).to eq 999 }
      eventually { expect(find_field('เงินสะสมเข้ากองทุนสงเคราะห์', disabled: true).value.to_i).to eq 99 }
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

        eventually { expect(cbx_pvf).to be_checked }
        eventually { expect(cbx_social_insurance).to be_checked }

        cbx_pvf.click
        cbx_social_insurance.click

        click_button('บันทึก')
        sleep(1)
        click_button('ตกลง')
        sleep(1)

        visit "/somsri_payroll#/employees/#{employees[0].id}"
        sleep(1)

        eventually { expect(cbx_pvf).to_not be_checked }
        eventually { expect(cbx_social_insurance).to_not be_checked }
      end
    end
  end
end
