describe 'Payroll Swap Page', js: true do  

  it 'should not see two menu on homepage' do
    visit "/#/"

    eventually { expect(page).to have_no_selector('#menu') }
  end
  
  it 'should see two menu and current page is Report' do
    visit "/#/report"
    find('#menu').click

    eventually { expect(page).to have_content 'Report Employee Report' }
    eventually { expect(URI.parse(current_url).to_s).to have_content 'report' }
  end

  it 'should see two menu and current page is Employee' do
    visit "/#/employees"
    find('#menu').click

    eventually { expect(page).to have_content 'Employee Employee Report' }
    eventually { expect(URI.parse(current_url).to_s).to have_content 'employees' }
  end

  it 'should swap report to employees page' do
    visit "/#/report"
    find('#menu').click
    click_link("Employee")
    sleep(1)
    find('#menu').click

    eventually { expect(page).to have_content 'Employee Employee Report' }
    eventually { expect(URI.parse(current_url).to_s).to have_content 'employees' }
  end

  it 'should swap employees to report page' do
    visit "/#/employees"
    find('#menu').click
    click_link("Report")
    sleep(1)
    find('#menu').click

    eventually { expect(page).to have_content 'Report Employee Report' }
    eventually { expect(URI.parse(current_url).to_s).to have_content 'report' }
  end
end
