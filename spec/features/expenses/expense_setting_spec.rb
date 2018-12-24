describe 'expense settings', js: true do
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
        expenses_id: 'vanz114214',
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

  it 'should go to setting expenses' do
    visit "/somsri#/expenses/setting"
    sleep(1)
    expect(page).to have_content ('ตั้งค่าประเภทค่าใช้จ่าย')
    expect(all('input[type="text"]')[0].value).to eq("car")
    expect(all('input[type="text"]')[1].value).to eq("ceo")
    expect(all('input[type="text"]')[2].value).to eq("kizuna")
  end

  it 'should go to setting expenses by click icon' do
    visit "/main#/setting"
    sleep(1)
    all('.row.justify-content-center .col-xs-3 img')[1].click
    sleep(1)
    expect(page).to have_content ('ตั้งค่าประเภทค่าใช้จ่าย')
    expect(all('input[type="text"]')[0].value).to eq("car")
    expect(all('input[type="text"]')[1].value).to eq("ceo")
    expect(all('input[type="text"]')[2].value).to eq("kizuna")
  end

  it 'should add expense category' do
    visit "/somsri#/expenses/setting"
    sleep(1)
    find("#add-new-item").click
    sleep(1)
    all('input[type="text"]')[3].set('eve')
    find("#save-btn").click
    click_button("ตกลง")
    sleep(1)
    expect(all('input[type="text"]')[0].value).to eq("car")
    expect(all('input[type="text"]')[1].value).to eq("ceo")
    expect(all('input[type="text"]')[2].value).to eq("kizuna")
    expect(all('input[type="text"]')[3].value).to eq("eve")
    expect(ExpenseTag.where(name: "eve").count).to eq(1)
    expense_tag_tree = JSON.parse(SiteConfig.get_cache.expense_tag_tree).collect{|ett| ett.deep_symbolize_keys}
    expect(ExpenseTag.where(id: expense_tag_tree[0][:id]).first.name).to eq("car")
    expect(expense_tag_tree[0][:lv]).to eq(2)
    expect(ExpenseTag.where(id: expense_tag_tree[1][:id]).first.name).to eq("ceo")
    expect(expense_tag_tree[1][:lv]).to eq(1)
    expect(ExpenseTag.where(id: expense_tag_tree[2][:id]).first.name).to eq("kizuna")
    expect(expense_tag_tree[2][:lv]).to eq(2)
    expect(ExpenseTag.where(id: expense_tag_tree[3][:id]).first.name).to eq("eve")
    expect(expense_tag_tree[3][:lv]).to eq(2)
  end

  it 'should not add expense category with blank name' do
    visit "/somsri#/expenses/setting"
    sleep(1)
    expect(ExpenseTag.count).to eq(3)
    find("#add-new-item").click
    sleep(1)
    find("#save-btn").click
    click_button("ตกลง")
    sleep(1)
    expect(all('input[type="text"]')[0].value).to eq("car")
    expect(all('input[type="text"]')[1].value).to eq("ceo")
    expect(all('input[type="text"]')[2].value).to eq("kizuna")
    expect(ExpenseTag.count).to eq(3)
    expense_tag_tree = JSON.parse(SiteConfig.get_cache.expense_tag_tree).collect{|ett| ett.deep_symbolize_keys}
    expect(ExpenseTag.where(id: expense_tag_tree[0][:id]).first.name).to eq("car")
    expect(expense_tag_tree[0][:lv]).to eq(2)
    expect(ExpenseTag.where(id: expense_tag_tree[1][:id]).first.name).to eq("ceo")
    expect(expense_tag_tree[1][:lv]).to eq(1)
    expect(ExpenseTag.where(id: expense_tag_tree[2][:id]).first.name).to eq("kizuna")
    expect(expense_tag_tree[2][:lv]).to eq(2)
  end

  it 'should add sub expense category' do
    visit "/somsri#/expenses/setting"
    sleep(1)
    all(".fa.fa-plus.color-green")[1].click
    sleep(1)
    all('input[type="text"]')[2].set('eve')
    find("#save-btn").click
    click_button("ตกลง")
    sleep(1)
    expect(all('input[type="text"]')[0].value).to eq("car")
    expect(all('input[type="text"]')[1].value).to eq("ceo")
    expect(all('input[type="text"]')[2].value).to eq("eve")
    expect(all('input[type="text"]')[3].value).to eq("kizuna")
    expect(ExpenseTag.where(name: "eve").count).to eq(1)
    expense_tag_tree = JSON.parse(SiteConfig.get_cache.expense_tag_tree).collect{|ett| ett.deep_symbolize_keys}
    expect(ExpenseTag.where(id: expense_tag_tree[0][:id]).first.name).to eq("car")
    expect(expense_tag_tree[0][:lv]).to eq(3)
    expect(ExpenseTag.where(id: expense_tag_tree[1][:id]).first.name).to eq("ceo")
    expect(expense_tag_tree[1][:lv]).to eq(2)
    expect(ExpenseTag.where(id: expense_tag_tree[2][:id]).first.name).to eq("eve")
    expect(expense_tag_tree[2][:lv]).to eq(1)
    expect(ExpenseTag.where(id: expense_tag_tree[3][:id]).first.name).to eq("kizuna")
    expect(expense_tag_tree[3][:lv]).to eq(3)
  end

  it 'should remove unuse expense category' do
    visit "/somsri#/expenses/setting"
    sleep(1)
    all(".fa.fa-times.color-red")[2].click
    sleep(1)
    find("#save-btn").click
    click_button("ตกลง")
    sleep(1)
    expect(all('input[type="text"]').length).to eq(2)
    expect(all('input[type="text"]')[0].value).to eq("car")
    expect(all('input[type="text"]')[1].value).to eq("ceo")
    expect(ExpenseTag.count).to eq(2)
    expect(ExpenseTag.where(name: "kizuna").count).to eq(0)
    expense_tag_tree = JSON.parse(SiteConfig.get_cache.expense_tag_tree).collect{|ett| ett.deep_symbolize_keys}
    expect(ExpenseTag.where(id: expense_tag_tree[0][:id]).first.name).to eq("car")
    expect(expense_tag_tree[0][:lv]).to eq(2)
    expect(ExpenseTag.where(id: expense_tag_tree[1][:id]).first.name).to eq("ceo")
    expect(expense_tag_tree[1][:lv]).to eq(1)
  end

  it 'should not remove used expense category' do
    visit "/somsri#/expenses/setting"
    sleep(1)
    all(".fa.fa-times.color-red")[0].click
    sleep(1)
    find("#save-btn").click
    click_button("ตกลง")
    sleep(1)
    expect(page).to have_content "ไม่สามารถลบประเภทค่าใช้จ่ายที่ยังถูกใช้งานอยู่ได้"
    expense_tag_tree = JSON.parse(SiteConfig.get_cache.expense_tag_tree).collect{|ett| ett.deep_symbolize_keys}
    expect(ExpenseTag.where(id: expense_tag_tree[0][:id]).first.name).to eq("car")
    expect(expense_tag_tree[0][:lv]).to eq(2)
    expect(ExpenseTag.where(id: expense_tag_tree[1][:id]).first.name).to eq("ceo")
    expect(expense_tag_tree[1][:lv]).to eq(1)
    expect(ExpenseTag.where(id: expense_tag_tree[2][:id]).first.name).to eq("kizuna")
    expect(expense_tag_tree[2][:lv]).to eq(2)
  end

  it 'should update expense category' do
    visit "/somsri#/expenses/setting"
    sleep(1)
    expect(ExpenseTag.count).to eq(3)
    all('input[type="text"]')[2].set('eve')
    sleep(1)
    find("#save-btn").click
    click_button("ตกลง")
    sleep(1)
    expect(all('input[type="text"]')[0].value).to eq("car")
    expect(all('input[type="text"]')[1].value).to eq("ceo")
    expect(all('input[type="text"]')[2].value).to eq("eve")
    expect(ExpenseTag.count).to eq(3)
    expect(ExpenseTag.where(name: "eve").count).to eq(1)
    expense_tag_tree = JSON.parse(SiteConfig.get_cache.expense_tag_tree).collect{|ett| ett.deep_symbolize_keys}
    expect(ExpenseTag.where(id: expense_tag_tree[0][:id]).first.name).to eq("car")
    expect(expense_tag_tree[0][:lv]).to eq(2)
    expect(ExpenseTag.where(id: expense_tag_tree[1][:id]).first.name).to eq("ceo")
    expect(expense_tag_tree[1][:lv]).to eq(1)
    expect(ExpenseTag.where(id: expense_tag_tree[2][:id]).first.name).to eq("eve")
    expect(expense_tag_tree[2][:lv]).to eq(2)
  end

  it 'should delete expense category if name is null' do
    visit "/somsri#/expenses/setting"
    sleep(1)
    expect(all('input[type="text"]')[0].value).to eq("car")
    expect(all('input[type="text"]')[1].value).to eq("ceo")
    expect(all('input[type="text"]')[2].value).to eq("kizuna")
    expect(ExpenseTag.count).to eq(3)
    all('input[type="text"]')[2].set('')
    sleep(1)
    find("#save-btn").click
    click_button("ตกลง")
    sleep(1)
    expect(all('input[type="text"]')[0].value).to eq("car")
    expect(all('input[type="text"]')[1].value).to eq("ceo")
    expect(ExpenseTag.count).to eq(2)
    expect(ExpenseTag.where(name: "kizuna").count).to eq(0)
    expense_tag_tree = JSON.parse(SiteConfig.get_cache.expense_tag_tree).collect{|ett| ett.deep_symbolize_keys}
    expect(ExpenseTag.where(id: expense_tag_tree[0][:id]).first.name).to eq("car")
    expect(expense_tag_tree[0][:lv]).to eq(2)
    expect(ExpenseTag.where(id: expense_tag_tree[1][:id]).first.name).to eq("ceo")
    expect(expense_tag_tree[1][:lv]).to eq(1)
  end

end
