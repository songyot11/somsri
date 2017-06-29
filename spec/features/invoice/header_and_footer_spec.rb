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

  let(:user) do
    u = User.make!
    u.add_role :admin
    u
  end

  before :all do
    skool = School.first
    if skool
      skool.invoice_header = 'โดย บรืษัท สามหน่อพอเพียง'
      skool.invoice_footer = 'โรงเรียนขอสงวนสิทธิ์ในการคืนเงินค่าแรกเข้าทุกกรณี'
      skool.save
    else
      School.make!(
        invoice_header: 'โดย บรืษัท สามหน่อพอเพียง',
        invoice_footer: 'โรงเรียนขอสงวนสิทธิ์ในการคืนเงินค่าแรกเข้าทุกกรณี'
      )
    end
  end

  before :each do
    invoice
    login_as(user, scope: :user)
  end

  def view_slip
    visit '/'
    find('.menu-btn.invoices').click()
    sleep(1)
    find('.menu-btn.slip').click()
    sleep(1)
    find('#tableHeader > tbody > tr:nth-child(1) > td:nth-child(1) > a').click()
    sleep(1)
  end

  describe 'header & footer' do
    it 'come from database' do
      view_slip

      eventually { expect(page).to have_content 'โดย บรืษัท สามหน่อพอเพียง' }
      eventually { expect(page).to have_content 'โรงเรียนขอสงวนสิทธิ์ในการคืนเงินค่าแรกเข้าทุกกรณี' }
    end
  end
end
