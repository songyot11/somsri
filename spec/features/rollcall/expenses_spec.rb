describe 'expense', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }
  let(:site_config) { SiteConfig.make!({ enable_rollcall: true }) }

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

  before do
    school
    user.add_role :admin
    login_as(user, scope: :user)
    site_config
    expenses
  end

  it 'should go to rollcall expenses' do
    visit "/somsri_rollcall#/expenses"
    sleep(1)
    expect(page).to have_content ('ใบเสร็จ')
  end

  it 'has add button' do
    visit "/somsri_rollcall#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    sleep(1)
    expect(page).to have_content ('เพิ่มรายการค่าใช้จ่าย')
  end

  it 'can cancel' do
    visit "/somsri_rollcall#/expenses"
    sleep(1)
    click_button("+ เพิ่มรายการ")
    sleep(1)
    click_button("ยกเลิก")
    sleep(1)
    expect(page).to have_content ('ค่ารถตู้ใหม่ผอ.')
  end

  it 'create expense' do
    visit "/somsri_rollcall#/expenses"
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
    visit "/somsri_rollcall#/expenses"
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
    visit "/somsri_rollcall#/expenses"
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
    visit "/somsri_rollcall#/expenses"
    sleep(1)
    expect(page).to have_content("vanz114214")
    find("a", text: "ลบ").click
    sleep(1)
    click_button("ตกลง")
    sleep(1)
    expect(page).to_not have_content("ค่ารถตู้ใหม่ผอ.")
  end

  it 'should go to rollcall expenses and cancel delete modal' do
    visit "/somsri_rollcall#/expenses"
    sleep(1)
    expect(page).to have_content("vanz114214")
    find("a", text: "ลบ").click
    sleep(1)
    click_button("ยกเลิก")
    sleep(1)
    expect(page).to have_content("ค่ารถตู้ใหม่ผอ.")
  end

end
