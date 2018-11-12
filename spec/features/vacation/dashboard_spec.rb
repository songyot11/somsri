describe 'Vacation Dasboard', js: true do

  let(:user) { user = User.make!({
    email: 'test@mail.com',
    password: '123456789',
    leave_allowance: 12
  })}

  let(:vacation_types) {
    VacationType.create!([
     { id: "1", name: "ลาป่วย" },
     { id: "2", name: "ลากิจ" },
     { id: "3", name: "สลับวันทำงาน" },
     { id: "4", name: "ทำงานที่บ้าน" },
    ])
  }

  let(:vacations) {
    Vacation.create!([
     { id: "1", detail: "ไม่สบายขอนอนที่บ้าน", vacation_type_id: "1", user_id: user.id },
     { id: "2", detail: "ไปเที่ยว", vacation_type_id: "2", user_id: user.id },
     { id: "3", detail: "ขอทำงานวันเสาร์แทน", vacation_type_id: "3", user_id: user.id },
     { id: "4", detail: "ช่างมาซ่อมไฟ ขอทำงานที่บ้านครับ", vacation_type_id: "4", user_id: user.id },
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
    expect(page).to have_content("11")
    expect(page).to have_content("/ #{user.leave_allowance}")
    expect(page).to have_content("ลาป่วย")
    expect(page).to have_content("ลากิจ")
    expect(page).to have_content("สลับวันทำงาน")

    expect(page).to have_content("รายการวันหยุดและคำขอ")
    expect(page).to have_content("ส่งคำขอ")
    expect(page).to have_content("ไม่สบายขอนอนที่บ้าน")
    expect(page).to have_content("ไปเที่ยว")
    expect(page).to have_content("ขอทำงานวันเสาร์แทน")
    expect(page).to have_content("ช่างมาซ่อมไฟ ขอทำงานที่บ้านครับ")

    expect(page).to have_content("รายการวันหยุดใน 7 วันข้างหน้า")
  end

end
