describe 'Payroll Report', js: true do
  let(:user)    {user = User.make!}

  
  it 'should see header table' do
    visit "/#/report"

    eventually { expect(page).to have_content 'รหัส + ชื่อ + เลขบัญชี เงินเดือน เงินหัก เงินเพิ่ม เงินเดือนสุทธิ' }
  end


end
