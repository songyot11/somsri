describe Parent do
  let(:parent) do
    Parent.make!({full_name: 'Xavi Pepe', mobile: "0999999"})
  end

  let(:parent_no_mobile) do
    Parent.make!({full_name: 'Xavi Pepe', mobile: nil})
  end

  let(:parent_deleted) do
    Parent.make!({full_name: 'แม่โดนลบ แล้วจร้า', mobile: "080-0987654", deleted_at: Time.now})
  end
  describe 'in invoice screen' do
    it 'display full name with tel. (in parentheses)' do
      full_name = parent.invoice_screen_full_name_display
      expect(full_name).to eq('Xavi Pepe (0999999)')
    end

    it 'display full name without parentheses, if there is no tel. number' do
      full_name = parent_no_mobile.invoice_screen_full_name_display
      expect(full_name).to eq('Xavi Pepe')
    end

    it 'should restore parent' do
      expect(Parent.where(id: parent_deleted.id).exists?).to be_falsey
      parent_deleted.restore
      expect(Parent.where(id: parent_deleted.id).exists?).to be_truthy
    end
  end
end
