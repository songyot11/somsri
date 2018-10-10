describe 'expense', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }
  let(:site_config) { SiteConfig.make!({ enable_expenses: true }) }

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
      ExpenseTag.make!(name: "ceo")
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
    eventually { expect(Expense.where(expenses_id: "111111", detail: "ซื้อของใช้ครับ").count).to eq 1 }
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
    eventually { expect(Expense.where(expenses_id: "pen12345", detail: "ซื้อปากกาและดินสอให้ ห้องเรียนแต่ละห้อง").count).to eq 1 }
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
    page.find("#tag input").set("car")
    page.find("#tag input").set("newone")
    page.find('.btn-green').click
    sleep(1)
    click_button("บันทึก")
    sleep(1)

    expect(ExpenseTag.where(name: "newone").count).to eq(1)
    expect(ExpenseTag.where(name: "car").count).to eq(1)

    expense = Expense.where(expenses_id: "pen002").first
    expect(expense.present?).to eq true
    expense_items = expense.expense_items
    expect(expense_items).to exist
    expect(["car", "newone"].include?(expense_items[0].expense_tag_items[0].expense_tag.name)).to eq true
    expect(["car", "newone"].include?(expense_items[0].expense_tag_items[1].expense_tag.name)).to eq true
  end

  it 'should edit tag expenses item' do
    visit "/somsri#/expenses/#{expenses[0].id}"
    sleep(1)
    page.find('#item').click
    page.first("#tag input").set("newone")
    sleep(1)
    click_button("บันทึก")
    sleep(1)
    puts ExpenseTag.all.inspect
    expect(ExpenseTag.where(name: "newone").count).to eq(1)
    expect(ExpenseTag.where(name: "car").count).to eq(1)
    expect(ExpenseTag.where(name: "ceo").count).to eq(1)

    expense = Expense.find(expenses[0].id)
    expect(expense.present?).to eq true
    expense_items = expense.expense_items
    expect(expense_items).to exist

    tag_names = ["car", "newone", "ceo"]
    expect(tag_names.include?(expense_items[0].expense_tag_items[0].expense_tag.name)).to eq true
    expect(tag_names.include?(expense_items[0].expense_tag_items[1].expense_tag.name)).to eq true
    expect(tag_names.include?(expense_items[0].expense_tag_items[2].expense_tag.name)).to eq true
  end

end
