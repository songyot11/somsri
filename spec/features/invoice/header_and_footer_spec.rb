describe 'invoice', js: true do
  let(:invoice_status_1) { InvoiceStatus.make! name: 'Active' }
  let(:invoice_status_2) { InvoiceStatus.make! name: 'Canceled' }

  let(:invoice) do
    Invoice.make!(
      user: user,
      invoice_status: invoice_status_1,
      line_items: [LineItem.make!, LineItem.make!]
    )
  end

  let(:school) do
    School.make!(
      invoice_header: 'โดย บรืษัท สามหน่อพอเพียง',
      invoice_footer: 'โรงเรียนขอสงวนสิทธิ์ในการคืนเงินค่าแรกเข้าทุกกรณี'
    )
  end

  let(:site_config) { SiteConfig.make!() }

  let(:user) do
    u = User.make!
    u.add_role :admin
    u
  end

  before :each do
    school
    site_config
    invoice
    login_as(user, scope: :user)
  end

  def view_slip
    visit "/invoices/#{invoice.id}/slip.pdf?show_as_html=true"
  end

  describe 'header & footer' do
    it 'come from database' do
      view_slip

      eventually { expect(page).to have_content 'โดย บรืษัท สามหน่อพอเพียง' }
      eventually { expect(page).to have_content 'โรงเรียนขอสงวนสิทธิ์ในการคืนเงินค่าแรกเข้าทุกกรณี' }
    end
  end
end
