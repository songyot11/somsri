describe 'Quotation list', js: true do
  let(:last_3_month_and_1_day) { (DateTime.now - 3.month - 1.day).strftime('%d/%m/%Y') }
  let(:tomorrow_date_string) { DateTime.now.tomorrow.strftime('%d/%m/%Y') }
  let(:user) { User.make! }
  let(:quotations) do
    [
      Quotation.make!(id: 1),
      Quotation.make!(id: 2),
      Quotation.make!(id: 3),
      Quotation.make!(id: 4),
      Quotation.make!(id: 5, quotation_status: :active),
      Quotation.make!(id: 6),
      Quotation.make!(id: 7),
      Quotation.make!(id: 8),
      Quotation.make!(id: 9),
      Quotation.make!(id: 10, created_at: DateTime.now - 3.month),
      Quotation.make!(id: 11, created_at: DateTime.now.tomorrow),
      Quotation.make!(id: 12, created_at: DateTime.now - 3.month - 1.day)
    ]
  end

  before do
    user.add_role :admin
    login_as(user, scope: :user)

    quotations
  end

  it 'can see all quotations' do
    visit 'somsri_invoice#/quotation'
    sleep(1)
    # have 10 quotations on the first page
    eventually { expect(all('#quotations-table > tbody > tr').count).to eq(10) }

    # expected to have 1 pages
    expect(all('li.pagination-page').count).to eq(1)
    expect(Quotation.count).to eq(12)
  end

  it 'can search' do
    visit 'somsri_invoice#/quotation'
    sleep(1)
    find('#searchField').set('1')
    sleep(1)
    # have 2 search results
    eventually { expect(all('#quotations-table > tbody > tr').count).to eq(2) }

    # expected to have 1 page
    expect(all('li.pagination-page').count).to eq(1)
  end

  it 'can filter by date range' do
    visit 'somsri_invoice#/quotation'
    sleep(1)
    find('#start_date').set(last_3_month_and_1_day)
    sleep(1)
    find('#end_date').set(tomorrow_date_string)
    sleep(1)

    eventually { expect(all('#quotations-table > tbody > tr').count).to eq(10) }
    eventually { expect(all('li.pagination-page').count).to eq(2) }
  end

  it 'can filter by date range and search' do
    visit 'somsri_invoice#/quotation'
    sleep(1)
    find('#start_date').set(last_3_month_and_1_day)
    sleep(1)
    find('#end_date').set(tomorrow_date_string)
    sleep(1)
    find('#searchField').set('1')
    sleep(1)

    eventually { expect(all('#quotations-table > tbody > tr').count).to eq(4) }
    eventually { expect(all('li.pagination-page').count).to eq(1) }
    eventually { expect(page).to have_content(quotations[0].student_name) }
    eventually { expect(page).to have_content(quotations[9].student_name) }
    eventually { expect(page).to have_content(quotations[10].student_name) }
    eventually { expect(page).to have_content(quotations[11].student_name) }
  end

  it 'should display paid when quotation is active' do
    visit 'somsri_invoice#/quotation'
    sleep(1)
    find('#searchField').set('5')
    sleep(1)
    eventually { expect(page).to have_content('ชำระแล้ว') }
  end
end
