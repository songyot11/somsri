describe 'Private Details', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  let(:employee) {
    Employee.make!({
      school_id: school.id,
      address: nil,
      tel: nil,
      birthdate: nil,
      status: nil,
      email: nil
    })
  }

  let(:payrolls) do
    [
      Payroll.make!({
        employee_id: employee.id,
        salary: 50_000,
        bonus: 15_000,
        tax: 750,
        effective_date: DateTime.new(2017, 1, 1)
      })
    ]
  end

  before :each do
    expect { payrolls }.to change{ Employee.count }.by 1
    login_as(user, scope: :user)
    open_testing_screen employee.id
  end

  def open_testing_screen(employee_id)
    visit "/#/employees/#{employee.id}"
    sleep(1)
    find('.employee-details .nav-tabs .orange').click
    sleep(1)
  end

  it 'can open private tab' do
    expect(page).to have_content('ที่อยู่ปัจจุบัน')
    expect(page).to have_content('โทรศัพท์')
    expect(page).to have_content('วันเกิด')
    expect(page).to have_content('สถานะ')
    expect(page).to have_content('อีเมล')
    expect(page).to have_select('สถานะ', selected: '')
  end

  it 'can insert private data' do
    # addres, tel, birthdate, status, email
    fill_in 'ที่อยู่ปัจจุบัน', with: '233/40'
    fill_in 'โทรศัพท์', with: '1234444'
    fill_in 'อีเมล', with: 'newemail@email.com'
    select 'สมรส', from: 'สถานะ'
    click_button 'บันทึก'
    sleep(1)
    click_button('ตกลง')
    sleep(1)

    open_testing_screen employee.id
    expect(find_field('ที่อยู่ปัจจุบัน').value).to eq '233/40'
    expect(find_field('โทรศัพท์').value).to eq '1234444'
    expect(find_field('อีเมล').value).to eq 'newemail@email.com'
    expect(page).to have_select('สถานะ', selected: 'สมรส')
  end

  describe 'after insertion' do
    before :each do
      # addres, tel, birthdate, status, email
      fill_in 'ที่อยู่ปัจจุบัน', with: '233/40'
      fill_in 'โทรศัพท์', with: '1234444'
      fill_in 'อีเมล', with: 'newemail@email.com'
      select 'สมรส', from: 'สถานะ'
      click_button 'บันทึก'
      sleep(1)
      click_button('ตกลง')
      sleep(1)
    end

    it 'can edit private data' do
      # addres, tel, birthdate, status, email
      fill_in 'ที่อยู่ปัจจุบัน', with: '1111/41'
      fill_in 'โทรศัพท์', with: '9066666'
      fill_in 'อีเมล', with: 'editedemail@email.com'
      select 'หย่าร้าง', from: 'สถานะ'
      click_button 'บันทึก'
      sleep(1)
      click_button('ตกลง')
      sleep(1)

      open_testing_screen employee.id
      expect(find_field('ที่อยู่ปัจจุบัน').value).to eq '1111/41'
      expect(find_field('โทรศัพท์').value).to eq '9066666'
      expect(find_field('อีเมล').value).to eq 'editedemail@email.com'
      expect(page).to have_select('สถานะ', selected: 'หย่าร้าง')
    end

    it 'can cancel editing' do
      # addres, tel, birthdate, status, email
      fill_in 'ที่อยู่ปัจจุบัน', with: '1111/41'
      fill_in 'โทรศัพท์', with: '9066666'
      fill_in 'อีเมล', with: 'editedemail@email.com'
      select 'หย่าร้าง', from: 'สถานะ'
      click_button 'ยกเลิก'
      sleep(1)

      open_testing_screen employee.id
      expect(find_field('ที่อยู่ปัจจุบัน').value).to eq '233/40'
      expect(find_field('โทรศัพท์').value).to eq '1234444'
      expect(find_field('อีเมล').value).to eq 'newemail@email.com'
      expect(page).to have_select('สถานะ', selected: 'สมรส')
    end
  end
end
