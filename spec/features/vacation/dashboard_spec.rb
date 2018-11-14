describe 'Vacation Dasboard', js: true do

  let(:user) { user = User.make!({
    email: 'test@mail.com',
    password: '123456789',
    leave_allowance: 12
  })}

  let(:vacation_types) {
    VacationType.create!([
     { id: "1", name: "ลาป่วย", deduce_days: 0 },
     { id: "2", name: "ลากิจ", deduce_days: 1 },
     { id: "3", name: "ลากิจครึ่งวันเช้า", deduce_days: 0.5 },
     { id: "4", name: "ลากิจครึ่งวันบ่าย", deduce_days: 0.5 },
     { id: "5", name: "สลับวันทำงาน", deduce_days: 0 },
     { id: "6", name: "ทำงานที่บ้าน", deduce_days: 0 },
    ])
  }

  let(:vacations) {
    Vacation.create!([
     { id: "1", detail: "ไม่สบายขอนอนที่บ้าน", vacation_type_id: "1", user_id: user.id },
     { id: "2", detail: "ไปเที่ยวครับ", vacation_type_id: "2", user_id: user.id },
     { id: "3", detail: "เช้าไปธุระครับ", vacation_type_id: "3", user_id: user.id },
     { id: "4", detail: "ลาตอนบ่ายไปหาหมอครับ", vacation_type_id: "4", user_id: user.id },
     { id: "5", detail: "ขอทำงานวันเสาร์แทนครับ", vacation_type_id: "5", user_id: user.id },
     { id: "6", detail: "ช่างมาซ่อมไฟ ขอทำงานที่บ้านครับ", vacation_type_id: "6", user_id: user.id }
    ])
  }

  before do
    vacation_types
    vacations
  end

  it 'should see dashboard' do
    user.add_role :finance_officer
    login_as(user, scope: :user)

    visit '/somsri#/vacation/dashboard'
    sleep(1)

    expect(page).to have_content("วันหยุดคงเหลือ")
    expect(page).to have_content("10")
    expect(page).to have_content("/ #{user.leave_allowance}")
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

end
