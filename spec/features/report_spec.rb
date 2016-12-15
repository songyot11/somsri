describe 'Payroll Report', js: true do  
  it 'should see header table' do
    visit "/#/report"

    eventually { expect(page).to have_content 'รหัส ชื่อ เลขบัญชี เงินเดือน เงินหัก เงินเพิ่ม เงินเดือนสุทธิ' }
    eventually { expect(page).to have_content 'รวมทั้งหมด' }
  end

  it 'should see month list' do
    visit "/#/report"

    find('#month-list').click
    
    eventually { expect(page).to have_content 'มกราคม 2016 กุมภาพันธ์ 2016' }
  end

  it 'should switch month' do
    visit "/#/report"
    find('#month-list').click
    click_on("มกราคม 2016")

    eventually { expect(page).to have_content 'รหัส ชื่อ เลขบัญชี เงินเดือน เงินหัก เงินเพิ่ม เงินเดือนสุทธิ' }
    eventually { expect(page).to have_content '8,000.00' }
  end
end
