describe 'Invoice-Report', js: true do

  let(:school) {School.create!({
    name: 'โรงเรียนแห่งหนึ่ง',
    address: '305 หมู่ 7 ตำบลหนองควาย อำเภอหางดง จังหวัด เชียงใหม่ database',
    zip_code: '50200',
    phone: '090 606 65xx',
    fax: '053 131 20x-x',
    daily_report_header: <<-HEAD
    <div class="row">
      <div class="col-xs-12">
        <b class="name-school">โรงเรียนแห่งหนึ่ง</b>
      </div>
    </div>
    <div class="row">
      <div class="col-xs-12">
        สามหน่อยพอเพียง จำกัด
      </div>
    </div>
    <div class="row">
      <div class="col-xs-12">
        305 หมู่ 7 ตำบลหนองควาย อำเภอหางดง จังหวัด เชียงใหม่ database 50200
      </div>
    </div>
    <div class="row">
      <div class="col-xs-12">
        <b>โทร/แฟซ์.</b> &nbsp;053 131 20x-x, 090 606 65xx
      </div>
    </div>
    <div class="row">
      <div class="col-xs-12">
        <b>E-mail:</b> &nbsp;info@sunshinekindergarten.com
      </div>
    </div>
    <div class="row">
      <div class="col-xs-12">
        <b>เลขประจำตัวผู้เสียภาษี: </b>&nbsp; 0505551005106 &nbsp;<b>สาขาที่: </b>&nbsp;000000
      </div>
    </div>
    HEAD
  })}

  let(:user) {User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:grade){Grade.create(
    name: "Kindergarten 1"
  )}

  let(:invoiceStatus1){InvoiceStatus.create!(
    name: 'Active'
  )}

  let(:invoiceStatus2){InvoiceStatus.create!(
    name: 'Canceled'
  )}

  let(:student1){Student.create!(
    full_name: 'มั่งมี ศรีสุข' ,
    nickname: 'รวย' ,
    gender_id: 1 ,
    grade_id: 2 ,
    classroom: '1A' ,
    classroom_number: 13 ,
    student_number: 2014 ,
    birthdate: Time.now
  )}

  let(:student2){Student.create!(
    full_name: 'สมศรี ณ บานาน่าโค๊ดดิ้ง' ,
    nickname: 'กล้วย' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 14 ,
    student_number: 2015 ,
    birthdate: Time.now
  )}

  let(:invoices) do
    [
      Invoice.create!({student_id: student1.id, invoice_status_id:  invoiceStatus1.id}),
      Invoice.create!({student_id: student2.id, invoice_status_id: invoiceStatus2.id})
    ]
  end

  let(:payment_methods) do
    [
      PaymentMethod.create!({payment_method: 'เงินสด', invoice_id: invoices[0].id , amount: '101' }),
      PaymentMethod.create!({payment_method: 'บัตรเครดิต', invoice_id: invoices[0].id , amount: '102' }),
      PaymentMethod.create!({payment_method: 'เช็คธนาคาร', invoice_id: invoices[0].id , amount: '103'}),
      PaymentMethod.create!({payment_method: 'เงินโอน', invoice_id: invoices[0].id , amount: '104'}),
    ]
  end

  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    grade
    payment_methods
  end

  it 'shoud show daily report page' do
    visit 'somsri_invoice#/daily_report'
    sleep(1)
    expect(page).to have_content("นำส่งเงิน")
  end

  it 'should go to repot menu when click ยกเลิก button' do
    visit 'somsri_invoice#/daily_report'
    sleep(1)
    click_button("ยกเลิก")
    sleep(1)
    expect(page).to have_content("ชำระเงิน ใบเสร็จ นำส่งเงิน รายงานการชำระ รายงานแยกตามประเภท")
  end

  it 'should go to print page when click on บันทึก button' do
    visit 'somsri_invoice#/daily_report'
    sleep(1)
    click_button("บันทึก")
    sleep(1)
    eventually { expect(page).to have_content("ใบนำส่งเงิน") }
    eventually { expect(page).to have_content("โรงเรียนแห่งหนึ่ง") }
    eventually { expect(page).to have_content("305 หมู่ 7 ตำบลหนองควาย อำเภอหางดง จังหวัด เชียงใหม่ database") }
    eventually { expect(page).to have_content("50200") }
    eventually { expect(page).to have_content("090 606 65xx") }
    eventually { expect(page).to have_content("053 131 20x-x") }
  end

  it 'should show sum of credit card payment' do
    visit 'somsri_invoice#/daily_report'
    sleep(1)
    expect(page).to have_content("102")
  end

  it 'should show sum of real cash payment' do
    visit 'somsri_invoice#/daily_report'
    sleep(1)
    expect(page).to have_content("101")
  end

  it 'should show sum of cheque payment' do
    visit 'somsri_invoice#/daily_report'
    sleep(1)
    expect(page).to have_content("103")
  end

  it 'should show sum of tranfer payment' do
    visit 'somsri_invoice#/daily_report'
    sleep(1)
    eventually { expect(page).to have_content("104") }
  end

  it 'should show the sum of all payment method' do
    visit 'somsri_invoice#/daily_report'
    sleep(1)
    expect(page).to have_content("410")
  end

  it 'should calculate ยอดเงินที่จัดส่ง' do
    visit 'somsri_invoice#/daily_report'
    sleep(1)
    fill_in 'เงินสด' ,  with: "10.00"
    fill_in 'บัตรเครดิต' ,  with: "10.00"
    fill_in 'เช็คธนาคาร' ,  with: "10.00"
    fill_in 'เงินโอน' ,  with: "10.00"
    sleep(1)
    eventually { expect(page).to have_content("40.00") }
  end
end
