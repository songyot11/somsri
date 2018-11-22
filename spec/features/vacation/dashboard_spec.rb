describe 'Vacation Dasboard', js: true do

  let(:requester) { requester = Employee.make!({
    email: 'test@mail.com',
    password: '123456789',
    leave_allowance: 12
  })}

  let!(:vacation_configs) {
    VacationConfig.create!({ id: 1,
      vacation_leave_advance_at_least: 3,
      switch_date_advance_at_least: 3,
      work_at_home_unit: 0,
      work_at_home_limit: 2,
      can_leave_half_day: true
    })
  }

  let!(:vacation_types) {
    VacationType.create!([
     { id: 1, name: "ลาป่วย", deduce_days: 0 },
     { id: 2, name: "ลากิจ", deduce_days: 1 },
     { id: 3, name: "ลากิจครึ่งวันเช้า", deduce_days: 0.5 },
     { id: 4, name: "ลากิจครึ่งวันบ่าย", deduce_days: 0.5 },
     { id: 5, name: "สลับวันทำงาน", deduce_days: 0 },
     { id: 6, name: "ทำงานที่บ้าน", deduce_days: 0 },
    ])
  }

  let(:vacations) {
    yesterday = Date.yesterday.strftime('%d/%m/%Y')
    today = Date.today.strftime('%d/%m/%Y')
    Vacation.create!([
     { detail: "ไม่สบายขอนอนที่บ้าน", vacation_type_id: "1", requester_id: requester.id, start_date: yesterday, end_date: yesterday },
     { detail: "ไปเที่ยวครับ", vacation_type_id: "2", requester_id: requester.id, start_date: yesterday, end_date: yesterday },
     { detail: "เช้าไปธุระครับ", vacation_type_id: "3", requester_id: requester.id, start_date: yesterday, end_date: yesterday },
     { detail: "ลาตอนบ่ายไปหาหมอครับ", vacation_type_id: "4", requester_id: requester.id, start_date: yesterday, end_date: yesterday },
     { detail: "ขอทำงานวันเสาร์แทนครับ", vacation_type_id: "5", requester_id: requester.id, start_date: yesterday, end_date: today },
     { detail: "ช่างมาซ่อมไฟ ขอทำงานที่บ้านครับ", vacation_type_id: "6", requester_id: requester.id, start_date: yesterday, end_date: yesterday }
    ])
  }

  before do
    requester.add_role :approver
    login_as(requester, scope: :employee)

    visit '/somsri#/vacation/dashboard/'
    sleep(1)
  end

  it 'should see dashboard' do
    vacations

    visit '/somsri#/vacation/dashboard/'
    sleep(1)

    expect(page).to have_content("วันหยุดคงเหลือ")
    expect(page).to have_content("#{requester.leave_remaining}")
    expect(page).to have_content("/ #{requester.leave_allowance}")
    expect(page).to have_content("ลาป่วย")
    expect(page).to have_content("ลากิจ")
    expect(page).to have_content("ลากิจครึ่งวันเช้า")
    expect(page).to have_content("ลากิจครึ่งวันบ่าย")
    expect(page).to have_content("สลับวันทำงาน")

    expect(page).to have_content("รายการวันหยุดและคำขอ")
    expect(page).to have_content("ส่งคำขอ")
    expect(page).to have_content("ไม่สบายขอนอนที่บ้าน")
    expect(page).to have_content("ไปเที่ยวครับ")
    expect(page).to have_content("เช้าไปธุระครับ")
    expect(page).to have_content("ลาตอนบ่ายไปหาหมอครับ")
    expect(page).to have_content("ขอทำงานวันเสาร์แทนครับ")
    expect(page).to have_content("ช่างมาซ่อมไฟ ขอทำงานที่บ้านครับ")

    expect(page).to have_content("รายการวันหยุดใน 7 วันข้างหน้า")
  end

  it 'should send sick leave request' do
    page.find('a[data-target="#leaveSubmissionModal"]').click
    sleep(1)

    within "#leaveSubmissionModal" do
      find("textarea").set 'เป็นไข้หวัดใหญ่'
      find("a").click
      sleep(1)
    end

    today = Time.now.strftime('%d/%m/%Y')
    expect(page).to have_content("ลาป่วย")
    expect(page).to have_content(today)
    expect(page).to have_content("เป็นไข้หวัดใหญ่")
    expect(Vacation.all.count).to eq(1)
  end

  it 'should send full day vacation leave request' do
    page.find('a[data-target="#leaveSubmissionModal"]').click
    sleep(1)

    start_leave_day = (Time.now + 5.days).strftime('%d/%m/%Y')
    end_leave_day = (Time.now + 6.days).strftime('%d/%m/%Y')

    within "#leaveSubmissionModal" do
      find('select').find(:xpath, 'option[2]').select_option
      fill_in 'start_date', with: start_leave_day
      fill_in 'end_date', with: end_leave_day
      find("textarea").set 'ไปไหนดีีครับ'
      find("a").click
      sleep(1)
    end

    expect(page).to have_content("ส่งคำขอสำเร็จแล้ว")
    click_on('ปิด')

    expect(page).to have_content("10") # leave remaining
    expect(page).to have_content(start_leave_day)
    expect(page).to have_content("ไปไหนดีีครับ")
    expect(Vacation.all.count).to eq(1)
  end

  it 'should send switch date request' do
    page.find('a[data-target="#leaveSubmissionModal"]').click
    sleep(1)

    from_date = (Time.now + 5.days).strftime('%d/%m/%Y')
    to_date = (Time.now + 6.days).strftime('%d/%m/%Y')

    within "#leaveSubmissionModal" do
      find('select').find(:xpath, 'option[4]').select_option
      fill_in 'start_date', with: from_date
      fill_in 'end_date', with: to_date
      find("textarea").set 'ขอสลับวันทำงานครับ'
      find("a").click
      sleep(1)
    end

    expect(page).to have_content("ส่งคำขอสำเร็จแล้ว")
    click_on('ปิด')

    expect(page).to have_content("12") # leave remaining
    expect(page).to have_content(from_date)
    expect(page).to have_content("ขอสลับวันทำงานครับ")
    expect(Vacation.all.count).to eq(1)
  end

end
