describe 'invoice report(ใบเสร็จ)', js: true do
  let(:user) do
    user = User.create!({
      email: 'test@mail.com',
      password: '123456789'
    })
    user.add_role :admin
    user
  end

  let(:invoice_status_1) { InvoiceStatus.make! name: 'Active' }
  let(:invoice_status_2) { InvoiceStatus.make! name: 'Canceled' }

  let(:invoices) do
    [
      Invoice.make!(student: Student.make!(first_name: 'สมชาย', last_name: 'ผลดี', nickname: 'ชาย')),
      Invoice.make!(student: Student.make!(first_name: 'สมหมาย', last_name: 'ผลดี')),
      Invoice.make!(student: Student.make!(full_name: 'นราพร แสงจันทร์')),
      Invoice.make!(student: Student.make!(full_name: 'กันตพงศ์ กุมกัน')),
      Invoice.make!(student: Student.make!(full_name: 'ทุน ลุงช่วย')),
      Invoice.make!(student: Student.make!(full_name: 'มัญชรี พวกทอง')),
      Invoice.make!(student: Student.make!(full_name: 'ผดุงเดช ชัยแก้ว')),
      Invoice.make!(student: Student.make!(full_name: 'แลง กู่งนะ')),
      Invoice.make!(student: Student.make!(full_name: 'ถิรพุทธิ์ แซ่ยะ')),
      Invoice.make!(student: Student.make!(full_name: 'ธัญชนก กันทาใจ')),
      Invoice.make!(student: Student.make!(full_name: 'อฐิษา ทาเรือง'))
    ]
  end

  let(:student){Student.create!(
    full_name: 'สมพล 1' ,
    nickname: 'กั้ง' ,
    gender_id: 2 ,
    grade_id: 4 ,
    classroom: '1A' ,
    classroom_number: 100 ,
    student_number: 9001 ,
    birthdate: Time.now
  )}

  let(:invoice_cancel) do
    Invoice.make!({
      student_id: student.id,
      invoice_status_id:  invoice_status_1.id,
      school_year: "2560",
      semester: "1",
      line_items: [
        LineItem.make!(:tuition, amount: 10000),
        LineItem.make!(amount: 3000)
      ]
    })
  end

  let(:payment_method) do
    PaymentMethod.create!({
      payment_method:'เงินสด',
      invoice_id: invoice_cancel.id
    })
  end

  before do |simple|
    unless simple.metadata[:skip_before]
      invoices
      login_as(user, scope: :user)
    end
  end

  it 'can see all invoices' do
    visit 'somsri_invoice#/invoice_report'
    sleep(1)
    # have 10 invoices on the first page
    eventually do
      expect( all('#tableHeader > tbody > tr').count ).to eq(10)
    end
    # expect to have 2 pages
    expect( all('li.pagination-page').count ).to eq(2)
  end

  it 'can search' do
    visit 'somsri_invoice#/invoice_report'
    sleep(1)
    find('#searchField').set('สม')
    sleep(1)
    # have 2 search results
    eventually do
      expect( all('#tableHeader > tbody > tr').count ).to eq(2)
    end
    # expect to have 1 page
    expect( all('li.pagination-page').count ).to eq(1)
  end

  it 'should display 10 row per page' do
    visit 'somsri_invoice#/invoice_report'
    sleep(5)
    expect(page).to have_selector("#tableHeader > tbody > tr", count: 10)
    expect(page).to have_content("‹ 12 ›")
  end

  it 'should display page 2' do
    login_as(user, scope: :user)
    visit 'somsri_invoice#/invoice_report'
    sleep(1)
    find('#student-report > div > div.row.report-content.container-fluid > div.row.row-centered > div > ul > li.pagination-next.ng-scope > a').click
    sleep(1)
    expect(page).to have_selector("#tableHeader > tbody > tr", count: 1)
    expect(page).to have_content("‹ 12 ›")
  end

  it 'canceled must blank', :skip_before do
    #init
    user.add_role :admin
    login_as(user, scope: :user)
    invoice_status_2
    payment_method

    visit 'somsri_invoice#/invoice_report'
    sleep(1)
    find("#tableHeader > tbody > tr:nth-child(1) > td:nth-child(10) > a").click
    sleep(1)
    click_on("ใช่")
    sleep(1)      
    visit 'somsri_invoice#/invoice_report'
    sleep(1)
    expect(page).to_not have_content("ยกเลิกใบเสร็จ")
  end

end
