describe 'expense', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }
  let(:site_config) do
    expense_tag_tree = [
      { id: expense_tags[0].id, cost: 0, lv: 2 },
      { id: expense_tags[1].id, cost: 0, lv: 1 },
      { id: expense_tags[2].id, cost: 0, lv: 2 },
    ]
    SiteConfig.make!({
      enable_expenses: true,
      expense_tag_tree: expense_tag_tree.to_json
    })
  end

  let(:expenses) do
    [
      Expense.make!(
        effective_date: DateTime.now,
        expenses_id:'vanz114214',
        detail:'ค่ารถตู้ใหม่ผอ.',
        total_cost: 7500000
      )
    ]
  end

  let(:expense_items) do
    [
      ExpenseItem.make!(
        expense_id: expenses[0].id,
        detail: 'ค่ารถ',
        amount: 1,
        cost: 7000000
      ),
      ExpenseItem.make!(
        expense_id: expenses[0].id,
        detail: 'ส่งรถ',
        amount: 1,
        cost: 500000
      )
    ]
  end

  let(:expense_tags) do
    [
      ExpenseTag.make!(name: "car"),
      ExpenseTag.make!(name: "ceo"),
      ExpenseTag.make!(name: "kizuna")
    ]
  end

  let(:expense_tag_items) do
    [
      ExpenseTagItem.make!(expense_tag_id: expense_tags[0].id, expense_item_id: expense_items[0].id),
      ExpenseTagItem.make!(expense_tag_id: expense_tags[1].id, expense_item_id: expense_items[0].id)
    ]
  end

  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    site_config
    expenses
    expense_tags
    expense_tag_items
  end

  it 'should go to rollcall expenses' do
    visit "/somsri#/expenses"
    sleep(1)
    expect(page).to have_content ('ใบเสร็จ')
  end

  it 'has add button' do
    visit "/somsri#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    sleep(1)
    expect(page).to have_content ('เพิ่มรายการค่าใช้จ่าย')
  end

  it 'can cancel' do
    visit "/somsri#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    sleep(1)
    click_button("ยกเลิก")
    sleep(1)
    expect(page).to have_content ('ค่ารถตู้ใหม่ผอ.')
  end

  it 'create expense' do
    visit "/somsri#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    sleep(1)
    page.find('#expenses_id').set("111111")
    page.find('#detail').set("ซื้อของใช้ครับ")
    page.find('#total_cost').set("2000.00")
    click_button("บันทึก")
    sleep(1)
    expect(page).to have_content ('ซื้อของใช้ครับ')
    expect(page).to have_content ("2000")
    eventually { expect(Expense.where(expenses_id: "111111", detail: "ซื้อของใช้ครับ", payment_method: "เงินสด").count).to eq 1 }
  end

  it 'create expense with credit card payment' do
    visit "/somsri#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    sleep(1)
    page.find('#expenses_id').set("111111")
    page.find('#detail').set("ซื้อของใช้ครับ")
    page.find('#total_cost').set("2000.00")
    page.find('#is-credit-card').click
    click_button("บันทึก")
    sleep(1)
    expect(page).to have_content ('ซื้อของใช้ครับ')
    expect(page).to have_content ("2000")
    eventually { expect(Expense.where(expenses_id: "111111", detail: "ซื้อของใช้ครับ", payment_method: "บัตรเครดิต").count).to eq 1 }
  end

  it 'create expense with cheque payment' do
    visit "/somsri#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    sleep(1)
    page.find('#expenses_id').set("111111")
    page.find('#detail').set("ซื้อของใช้ครับ")
    page.find('#total_cost').set("2000.00")
    page.find('#is-cheque').click
    page.find('#cheque-bank-name').set("กสิกรไทย")
    page.find('#cheque-number').set("1234567890")
    page.find('#cheque-date').set("12/11/18")
    click_button("บันทึก")
    sleep(1)
    expect(page).to have_content ('ซื้อของใช้ครับ')
    expect(page).to have_content ("2000")
    eventually { expect(Expense.where(
      expenses_id: "111111",
      detail: "ซื้อของใช้ครับ",
      payment_method: "เช็คธนาคาร",
      cheque_bank_name: "กสิกรไทย",
      cheque_number: "1234567890",
      cheque_date: "12/11/18",
    ).count).to eq 1 }
  end

  it 'create expense with transfer payment' do
    visit "/somsri#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    sleep(1)
    page.find('#expenses_id').set("111111")
    page.find('#detail').set("ซื้อของใช้ครับ")
    page.find('#total_cost').set("2000.00")
    page.find('#is-transfer').click
    page.find('#transfer-bank-name').set("กสิกรไทย")
    page.find('#transfer-date').set("12/11/18")
    click_button("บันทึก")
    sleep(1)
    expect(page).to have_content ('ซื้อของใช้ครับ')
    expect(page).to have_content ("2000")
    eventually { expect(Expense.where(
      expenses_id: "111111",
      detail: "ซื้อของใช้ครับ",
      payment_method: "เงินโอน",
      transfer_bank_name: "กสิกรไทย",
      transfer_date: "12/11/18"
    ).count).to eq 1 }
  end

  it 'change tab' do
    visit "/somsri#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    sleep(1)
    page.find('#item').click
    sleep(1)
    expect(page).to have_content ('รายการ')
    expect(page).to have_content ('จำนวน')
    expect(page).to have_content ('ราคาต่อหน่วย')
    expect(page).to have_content ('ราคารวม')
  end

  it 'add items list and save' do
    visit "/somsri#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    page.find('#expenses_id').set("pen12345")
    page.find('#detail').set("ซื้อปากกาและดินสอให้ ห้องเรียนแต่ละห้อง")
    page.find('#total_cost').set("1500.00")
    sleep(1)
    page.find('#item').click
    sleep(1)
    page.find('#item_detail').set("ซื้อปากกา")
    page.find('#item_amount').set("50")
    page.find('#item_cost').set("30.00")
    page.find('.btn-green').click
    sleep(1)
    click_button("บันทึก")
    sleep(1)
    expect(page).to have_content ("ซื้อปากกาและดินสอให้ ห้องเรียนแต่ละห้อง")
    expect(page).to have_content ("1500")
    eventually { expect(Expense.where(expenses_id: "pen12345", detail: "ซื้อปากกาและดินสอให้ ห้องเรียนแต่ละห้อง", payment_method: "เงินสด").count).to eq 1 }
    eventually { expect(ExpenseItem.where(detail: "ซื้อปากกา", amount: "50", cost: "30.00").count).to eq 1 }
  end

  it 'should go to rollcall expenses and delete item' do
    visit "/somsri#/expenses"
    sleep(1)
    expect(page).to have_content("vanz114214")
    find("a", text: "ลบ").click
    sleep(1)
    click_button("ตกลง")
    sleep(1)
    expect(page).to_not have_content("ค่ารถตู้ใหม่ผอ.")
  end

  it 'should go to rollcall expenses and cancel delete modal' do
    visit "/somsri#/expenses"
    sleep(1)
    expect(page).to have_content("vanz114214")
    find("a", text: "ลบ").click
    sleep(1)
    click_button("ยกเลิก")
    sleep(1)
    expect(page).to have_content("ค่ารถตู้ใหม่ผอ.")
  end

  it 'should tag expenses item' do
    visit "/somsri#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    page.find('#expenses_id').set("pen002")
    page.find('#detail').set("ซื้อปากกาและดินสอให้ ห้องเรียนแต่ละห้อง")
    page.find('#total_cost').set("1500.00")
    sleep(1)
    page.find('#item').click
    sleep(1)
    page.find('#item_detail').set("ซื้อปากกา")
    page.find('#item_amount').set("50")
    page.find('#item_cost').set("30.00")
    page.find("#tags-0").click
    page.find('#tags-0 span.ng-binding.ng-scope', text: 'ceo').click
    page.find('.btn-green').click
    sleep(1)
    click_button("บันทึก")
    sleep(1)
    expense = Expense.where(expenses_id: "pen002").first
    expect(expense.present?).to eq true
    expense_items = expense.expense_items
    expect(expense_items).to exist
    expect(["car", "ceo"].include?(expense_items[0].expense_tag_items[0].expense_tag.name)).to eq true
    expect(["car", "ceo"].include?(expense_items[0].expense_tag_items[1].expense_tag.name)).to eq true
  end

  it 'should edit tag expenses item' do
    visit "/somsri#/expenses/#{expenses[0].id}"
    sleep(1)
    page.find('#item').click
    page.find("#tags-0").click
    page.find('#tags-0 span.ng-binding.ng-scope', text: 'kizuna').click
    sleep(1)
    click_button("บันทึก")
    sleep(1)

    expense = Expense.find(expenses[0].id)
    expect(expense.present?).to eq true
    expense_items = expense.expense_items
    expect(expense_items).to exist

    tag_names = []
    expect(expense_items[0].expense_tag_items[0].expense_tag.name).to eq "kizuna"
  end

end
