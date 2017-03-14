describe Parent do
  describe 'in invoice screen' do
    it 'display full name with tel. (in parentheses)' do
      parent = Parent.make(full_name: 'Xavi Pepe', mobile: '0999999')
      full_name = parent.invoice_screen_full_name_display
      expect(full_name).to eq('Xavi Pepe (0999999)')
    end

    it 'display full name without parentheses, if there is no tel. number' do
      parent = Parent.make(full_name: 'Xavi Pepe', mobile: '')
      full_name = parent.invoice_screen_full_name_display
      expect(full_name).to eq('Xavi Pepe')
    end
  end
end
