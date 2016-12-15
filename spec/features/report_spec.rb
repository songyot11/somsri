describe 'Payroll Report', js: true do  
  it 'should see header table' do
    visit "/#/report"

    eventually { expect(page).to have_content 'รหัส ชื่อ เลขบัญชี เงินเดือน เงินหัก เงินเพิ่ม เงินเดือนสุทธิ' }
    eventually { expect(page).to have_content 'รวมทั้งหมด' }
  end

  it 'should see month list' do
    visit "/#/report"

    find('#month-list').click
    eventually { expect(page).to have_content 'มกราคม 2016 กุมพาพันธ์ 2016' }
  end
end
