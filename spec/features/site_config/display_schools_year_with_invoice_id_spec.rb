describe 'SiteConfig Display Schools Year With Invoice Id', js: true do
  let(:school) { School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  let(:grade){Grade.make!(
    name: "Kindergarten 1"
  )}

  let(:gender)do
    Gender.make!(name: "Female")
  end

  let(:invoiceStatus1){InvoiceStatus.make!(
    name: 'Active'
  )}

  let(:student1){Student.make!(
    full_name: 'มั่งมี ศรีสุข' ,
    nickname: 'รวย' ,
    gender_id: gender.id ,
    grade_id: grade.id ,
    classroom: '1A' ,
    classroom_number: 13 ,
    student_number: 2014 ,
    birthdate: Time.now
  )}

  let(:parent){ Parent.make!({ full_name: 'สมศรี ใบเสร็จ' }) }

  let(:invoice) do
    Invoice.make!({
      student_id: student1.id,
      invoice_status_id:  invoiceStatus1.id,
      grade_name: "Kindergarten 1",
      user_id: user.id,
      parent_id: parent.id,
      school_year: "2777"
    })
  end

  let(:payment_method) do
    PaymentMethod.make!({payment_method: 'เงินสด', invoice_id: invoice.id , amount: '101' })
  end

  let(:display_schools_year_with_invoice_id) { SiteConfig.make!({ display_schools_year_with_invoice_id: true }) }
  let(:not_display_schools_year_with_invoice_id) { SiteConfig.make!({ display_schools_year_with_invoice_id: false }) }

  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    grade
    payment_method
  end

  it 'should display schools year with invoice id' do
    display_schools_year_with_invoice_id
    visit "/somsri_invoice#/invoice/#{invoice.id}/slip"
    sleep(1)
    expect(page).to have_content("เลขที่ใบเสร็จ #{invoice.id}/2777")
  end

  it 'should not display schools year with invoice id' do
    not_display_schools_year_with_invoice_id
    visit "/somsri_invoice#/invoice/#{invoice.id}/slip"
    sleep(1)
    expect(page).to have_content("เลขที่ใบเสร็จ #{invoice.id}")
  end
end
