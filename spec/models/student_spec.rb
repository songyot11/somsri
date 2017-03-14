describe Student do
  describe 'in invoice screen' do
    it 'display full name with nick name (in parentheses)' do
      student = Student.make(first_name: 'Xavi', last_name: 'Pepe', nickname: 'Tom')
      full_name = student.invoice_screen_full_name_display
      expect(full_name).to eq('Xavi Pepe (Tom)')
    end

    it 'display full name without parentheses, if there is no nick name' do
      student = Student.make(first_name: 'Xavi', last_name: 'Pepe', nickname: '')
      full_name = student.invoice_screen_full_name_display
      expect(full_name).to eq('Xavi Pepe')
    end
  end
end
