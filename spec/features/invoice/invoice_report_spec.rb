describe 'invoice report(ใบเสร็จ)', js: true do
  let(:user) do
    user = User.create!({
      email: 'test@mail.com',
      password: '123456789'
    })
    user.add_role :admin
    user
  end

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

  before :each do
    invoices
    login_as(user, scope: :user)
  end

  it 'can see all invoices' do
    visit 'somsri_invoice#/invoice_report'
    sleep(1)
    # have 10 invoices on the first page
    eventually do
      expect( all('tr.tr-invoice').count ).to eq(10)
    end
    # expect to have 2 pages
    expect( all('li.pagination-page').count ).to eq(2)
  end

  it 'can search' do
    visit 'somsri_invoice#/invoice_report'
    sleep(1)
    find('#searchField').set('สม')
    find('#searchButton').click()
    sleep(1)
    # have 2 search results
    eventually do
      expect( all('tr.tr-invoice').count ).to eq(2)
    end
    # expect to have 1 page
    expect( all('li.pagination-page').count ).to eq(1)
  end
end
