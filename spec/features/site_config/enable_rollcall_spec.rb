describe 'SiteConfig Enable Rollcall', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  let(:enable_rollcall) { SiteConfig.make!({ enable_rollcall: true }) }
  let(:disable_rollcall) { SiteConfig.make!({ enable_rollcall: false }) }

  let(:employee) do
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
    })
  end

  before do
    user.add_role :admin
    login_as(user, scope: :user)
  end

  describe 'enable rollcall' do
    before do
      enable_rollcall
    end

    it 'should go to rollcall report' do
      visit "/somsri_rollcall#"
      sleep(1)
      expect(page).to have_current_path("/somsri_rollcall")
    end

    it 'should see rollcall on menu' do
      visit "/"
      sleep(1)
      expect(page).to have_content("นับแถว")
    end

    it 'should display PIN' do
      visit "/somsri_payroll#/employees/#{employee.id}"
      sleep(1)
      expect(page).to have_content("PIN Number")
    end
  end

  describe 'disable rollcall' do
    before do
      disable_rollcall
    end

    # it 'should not go to rollcall report' do
    #   visit "/somsri_rollcall#"
    #   sleep(1)
    #   expect(page).to have_current_path("/")
    # end

    it 'should not see rollcall on menu' do
      visit "/"
      sleep(1)
      expect(page).to_not have_content("นับแถว")
    end

    it 'should not display PIN' do
      visit "/somsri_payroll#/employees/#{employee.id}"
      sleep(1)
      expect(page).to_not have_content("PIN Number")
    end
  end
end
