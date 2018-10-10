describe 'expense tag', js: true do
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

  it 'should go to setting expenses tag' do
    visit "/somsri#/setting/expenses_tag"
    sleep(1)
    expect(page).to have_content ('ตั้งค่าแท็กค่าใช้จ่าย')
  end

  it 'can add expense tag' do
    visit "/somsri#/setting/expenses_tag"
    sleep(1)
    expect(ExpenseTag.where(name: "new tag", description: "แท็กใหม่").count).to eq 0
    expect(ExpenseTag.count).to eq 2
    page.find("#add-item").click
    sleep(1)
    page.find('#name2').set("new tag")
    page.find('#description2').set("แท็กใหม่")
    click_button("บันทึก")
    sleep(1)
    click_button("ตกลง")
    sleep(1)
    expect(ExpenseTag.where(name: "new tag", description: "แท็กใหม่").count).to eq 1
    expect(ExpenseTag.count).to eq 3
  end

  it 'can edit expense tag' do
    visit "/somsri#/setting/expenses_tag"
    sleep(1)
    expect(ExpenseTag.where(name: "new tag", description: "แท็กใหม่").count).to eq 0
    expect(ExpenseTag.count).to eq 2

    page.find('#name1').set("new tag")
    page.find('#description1').set("แท็กใหม่")
    click_button("บันทึก")
    sleep(1)
    click_button("ตกลง")
    sleep(1)

    expect(ExpenseTag.where(name: "new tag", description: "แท็กใหม่").count).to eq 1
    expect(ExpenseTag.count).to eq 2
  end

  it 'can delete expense tag' do
    visit "/somsri#/setting/expenses_tag"
    sleep(1)
    expect(ExpenseTag.count).to eq 2
    expect(ExpenseTagItem.count).to eq 2

    page.find('#remove0').click
    click_button("บันทึก")
    sleep(1)
    click_button("ตกลง")
    sleep(1)

    expect(ExpenseTag.count).to eq 1
    expect(ExpenseTagItem.count).to eq 1
  end

end
