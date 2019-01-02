describe 'Private Details', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }

  let(:user) { User.make!({ school_id: school.id }) }

  let(:employee) {
    Employee.make!({
      school_id: school.id,
      address: nil,
      tel: nil,
      birthdate: nil,
      status: nil
    })
  }

  let(:individuals) do
    [
      Individual.make!(emergency_call_id: employee.id)
    ]
  end

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
    user.add_role :admin
    expect { payrolls }.to change{ Employee.count }.by 1
    login_as(user, scope: :user)
    individuals
    open_testing_screen employee.id
  end

  def open_testing_screen(employee_id)
    visit "/somsri_payroll#/employees/#{employee.id}"
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
    eventually { expect(find_field('ที่อยู่ปัจจุบัน').value).to eq '233/40' }
    eventually { expect(find_field('โทรศัพท์').value).to eq '1234444' }
    eventually { expect(find_field('อีเมล').value).to eq 'newemail@email.com' }
    eventually { expect(page).to have_select('สถานะ', selected: 'สมรส') }
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

    it 'can create new emergency call individual' do
      click_link('+ เพิ่มข้อมูล')
      sleep(1)
      find("label", text: 'นางสาว').click()
      fill_in 'ชื่อจริง', with: 'กาไก่'
      fill_in 'นามสกุล', with: 'ขาไข่'
      fill_in 'ความสัมพันธ์', with: 'โศก'
      fill_in 'Name', with: 'gargai'
      fill_in 'Middle Name', with: 'ooo'
      fill_in 'Surname', with: 'karkai'
      fill_in 'หมายเลขโทรศัพท์', with: '1111-41-0--000'
      find(:css, ".modal-body input[id$='email']").set('test@test.com')
      find(:css, ".modal-body button[type='submit']").click()

      sleep(1)
      expect(page).to have_content('นางสาว กาไก่ ขาไข่')
    end

    it 'can edit emergency call individual' do
      individual_name = "#{individuals[0].prefix_thai} #{individuals[0].first_name_thai} #{individuals[0].last_name_thai}"
      expect(page).to have_content(individual_name)
      click_link(individual_name)
      sleep(1)
      find("label", text: 'นางสาว').click()
      fill_in 'ชื่อจริง', with: 'กาไก่'
      fill_in 'นามสกุล', with: 'ขาไข่'
      fill_in 'ความสัมพันธ์', with: 'โศก'
      fill_in 'Name', with: 'gargai'
      fill_in 'Middle Name', with: 'ooo'
      fill_in 'Surname', with: 'karkai'
      fill_in 'หมายเลขโทรศัพท์', with: '1111-41-0--000'
      find(:css, ".modal-body input[id$='email']").set('test@test.com')
      find(:css, ".modal-body button[type='submit']").click()
      sleep(1)
      expect(page).to have_content('นางสาว กาไก่ ขาไข่')
      expect(page).to_not have_content(individual_name)
    end

    it 'can delete emergency call individual' do
      individual_name = "#{individuals[0].prefix_thai} #{individuals[0].first_name_thai} #{individuals[0].last_name_thai}"
      expect(page).to have_content(individual_name)
      find(:css, ".fa.fa-times").click()
      sleep(1)
      find(".modal-body button", text: "ตกลง").click()
      sleep(1)
      expect(page).to_not have_content(individual_name)
    end

  end
end
