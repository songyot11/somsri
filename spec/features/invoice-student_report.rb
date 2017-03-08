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
      payment_method1 = PaymentMethod.create!({payment_method:'เงินสด' , invoice_id: invoice1.id })
    ]
  end

  before do
    login_as(user, scope: :user)
    grade
    invoice
  end

  it 'should show report page' do
    visit 'somsri_invoice#/report'

    expect(page).to have_content("รายงานค่าเทอม")
    expect(page).to have_content("รายงานประจำวัน")
  end

  it 'should show student report page' do
    visit 'somsri_invoice#/student_report'

    expect(page).to have_content "รหัส"
  end

  it 'should show unpaid student on report' do
    #แสดงนักเรียนที่ยังไมไ่ด้ชำระเงิน
    visit 'somsri_invoice#/student_report'

    expect(page).to have_content("มั่งมี")
    expect(page).to have_content("ยกเลิก")
  end

  it 'should show paid student on report' do
    visit 'somsri_invoice#/student_report'

    expect(page).to have_content("สมศรี")
    expect(page).to have_content("เงินสด")
    expect(page).to have_content("ชำระแล้ว")
  end

  it 'can sort by grade' do
    #สามารถเลือกดูตามระดับชั้นเรียนได้
    visit 'somsri_invoice#/student_report'
    sleep(1)
    find('#grade-list').click
    sleep(1)
    click_on("Kindergarten 1")
    expect(page).to have_content("มั่งมี")
  end
end
