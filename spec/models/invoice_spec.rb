describe Invoice do
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

  let(:invoice) { invoices.last }

  before :each do
    invoices
  end

  describe '.search' do
    it 'can handle blank keyword' do
      expect(Invoice.search(nil).count).to eq(Invoice.count)
      expect(Invoice.search('').count).to eq(Invoice.count)
    end

    it 'can find by full_name' do
      puts invoices.collect{|i| i.student.full_name}.to_s
      expect(Invoice.search('สมชาย ผลดี').count).to eq(1)
      expect(Invoice.search('ผลดี').count).to eq(2)
    end

    it 'can find by nickname' do
      expect(Invoice.search('ชาย').count).to eq(1)
    end

    it 'can find by invoice id' do
      expect(Invoice.search(invoice.id).count).to eq(1)
    end
  end

end
