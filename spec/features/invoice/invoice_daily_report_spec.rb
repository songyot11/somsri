describe 'Invoice-Report', js: true do
  let(:user) {user = User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:grade){grade = Grade.create(
    name: "Kindergarten 1"
  )}

  let(:invoiceStatus1){invoiceStatus1 = InvoiceStatus.create!(
    name: 'Active'
  )}

  let(:invoiceStatus2){invoiceStatus2 = InvoiceStatus.create!(
    name: 'Canceled'
  )}

  let(:student1){student1 = Student.create!(
    full_name: 'มั่งมี ศรีสุข' ,
    nickname: 'รวย' ,
    gender_id: 1 ,
    grade_id: 2 ,
    classroom: '1A' ,
    classroom_number: 13 ,
    student_number: 2014 ,
    birthdate: Time.now
  )}

  let(:student2){student2 = Student.create!(
    full_name: 'สมศรี ณ บานาน่าโค๊ดดิ้ง' ,
    nickname: 'กล้วย' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 14 ,
    student_number: 2015 ,
    birthdate: Time.now
  )}

  let(:invoice) do
    [
      invoice1 = Invoice.create!({student_id: student1.id, invoice_status_id:  invoiceStatus1.id}),
      invoice2 = Invoice.create!({student_id: student2.id, invoice_status_id: invoiceStatus2.id}),
      payment_method1 = PaymentMethod.create!({payment_method:'เงินสด' , invoice_id: invoice1.id , amount: '101' }),
      payment_method2 = PaymentMethod.create!({payment_method:'บัตรเครดิต' , invoice_id: invoice1.id , amount: '102' }),
      payment_method3 = PaymentMethod.create!({payment_method: 'เช็คธนาคาร' , invoice_id: invoice1.id , amount: '103'}),
      payment_method4 = PaymentMethod.create!({payment_method: 'เงินโอน' , invoice_id: invoice1.id , amount: '104'}),
    ]
  end

  before do
    login_as(user, scope: :user)
    grade
    invoice
  end

  it 'shoud show daily report page' do
    visit 'somsri_invoice#/daily_report'

    expect(page).to have_content("นำส่งเงิน")
  end

  it 'should go to repot menu when click ยกเลิก button' do
    visit 'somsri_invoice#/daily_report'
    click_button("ยกเลิก")

    expect(page).to have_content("รายงานค่าเทอม")
  end

  it 'should go to print page when click on บันทึก button' do
    visit 'somsri_invoice#/daily_report'
    click_button("บันทึก")

    expect(page).to have_content("ใบนำส่งเงิน")
  end

  it 'should show sum of credit card payment' do
    visit 'somsri_invoice#/daily_report'

    expect(page).to have_content("102")
  end

  it 'should show sum of real cash payment' do
    visit 'somsri_invoice#/daily_report'

    expect(page).to have_content("101")
  end

  it 'should show sum of cheque payment' do
    visit 'somsri_invoice#/daily_report'

    expect(page).to have_content("103")
  end

  it 'should show sum of tranfer payment' do
    visit 'somsri_invoice#/daily_report'

    expect(page).to have_content("104")
  end

  it 'should show the sum of all payment method' do
    visit 'somsri_invoice#/daily_report'

    expect(page).to have_content("410")
  end

  it 'should calculate ยอดเงินที่จัดส่ง' do
    visit 'somsri_invoice#/daily_report'

    fill_in 'เงินสด' ,  with: "10.00"
    fill_in 'บัตรเครดิต' ,  with: "10.00"
    fill_in 'เช็คธนาคาร' ,  with: "10.00"
    fill_in 'เงินโอน' ,  with: "10.00"

    expect(page).to have_content("40.00")
  end
end
