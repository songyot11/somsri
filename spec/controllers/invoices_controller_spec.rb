describe InvoicesController do
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

  let(:admin) do
    user = User.make!
    user.add_role :admin
    user
  end

  before :each do
    sign_in admin
    invoices
  end

  describe '#index' do
    describe 'filter invoices' do
      it 'can filter' do
        get :index, params: { search_keyword: 'ผลดี' }
        expect(assigns[:invoices].length).to eq 2
      end

      it 'can handle if current page is greater than number of pages' do
        get :index, params: { search_keyword: 'ผลดี', page: 3 }
        expect(assigns[:invoices].length).to eq 2
        expect(assigns[:invoices].current_page).to eq 1
      end
    end
  end
end
