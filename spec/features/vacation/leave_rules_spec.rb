describe 'Vacation Leave Rules', js: true do

  let(:admin) { User.make! }
  let(:employee) { Employee.make! }

  let!(:vacation_leave_rules) {
    VacationLeaveRule.create!({
      updated_by: admin,
      message: """
        <h3><span style='color:#ffab04'>การลาป่วย</span></h3>
        <p>- ลาป่วย ตามสมควร ถ้าเกิน 3 วันต้องมีหนังสือรับรองจากแพทย์ หรือ ใบเสร็จรับเงินจากคลีนิค, โรงพยาบาล</p>
        &nbsp;
        <h3><span style='color:#ffab04'>การลากิจ</span></h3>
        &nbsp;
        <p>- ต้องลาล่วงหน้าอย่างน้อย 3 วัน เป็นลายลักษณ์อักษร ทาง Banana Vacation (<a href='http://vacation.bananacoding.com'>http://vacation.bananacoding.com</a>), email หรือ slack</p>
        <p>- สำหรับพนักงานทำงานไม่ถึงหนึ่งปี จะลาได้ไม่เกิน 7 วัน</p>
        <p>- สำหรับพนักงานเกินหนึ่งปี จะเป็นไปตามอายุงาน และจะเพิ่มปีละ 2 วัน เช่นเข้าทำงานได้ 2 ปีจะได้วันหยุด 11 วัน</p>
        <p>- สำหรับพนักงานช่วงทดลองงาน 3 เดือน ลากิจ จะเป็นการลาแบบไม่ได้เงินเดือน ตามจำนวณวันที่ลา เช่นเงินเดือน 10,000 บาท พนักงานต้องทำงานวันละ 8 ชัวโมงต่อวัน 20 วันต่อเดือน คือหัก วันละ 500 บาท</p>
        &nbsp;
        <h3><span style='color:#ffab04'>การทำงานที่บ้าน</span></h3>
        &nbsp;
        <p>- ทำงานนอกสถานที่ หรือ ที่บ้าน สามารถทำได้ 2 วันต่อสัปดาห์ ต้องแจ้ง ทาง Banana Vacation (<a href='http://vacation.bananacoding.com'>http://vacation.bananacoding.com</a>), email หรือ slack</p>
        &nbsp;
        <p>เพิ่มเติมตามกฎหมายแรงงานที่ <a href='http://www.mol.go.th/employee/rihgt_labor%20low'>http://www.mol.go.th/employee/rihgt_labor%20low</a></p>
        &nbsp;
      """
    })
  }

  before do
    admin.add_role :admin
  end

  it 'admin should able to update leave rules' do
    login_as(admin)

    visit '/somsri#/vacation/leave_rules'
    sleep(1)

    fill_in_ckeditor 'new leave rules'
    click_on("บันทึก")

    ckeditor_content = page.evaluate_script("CKEDITOR.instances.editor2.getData();")
    expect(ckeditor_content).to have_content("new leave rules")
    expect(page).to have_content("บันทึกข้อมูลเรียบร้อยแล้ว")
  end

  it 'employee should see leave rule' do
    login_as(employee, scope: :employee)

    visit '/somsri#/vacation/leave_rules'
    sleep(1)

    expect(page).to have_content("ระเบียบวันลา")
    expect(page).to have_content("การลาป่วย")
    expect(page).to have_content("- ลาป่วย ตามสมควร ถ้าเกิน 3 วันต้องมีหนังสือรับรองจากแพทย์ หรือ ใบเสร็จรับเงินจากคลีนิค, โรงพยาบาล")
    expect(page).to have_content("การลากิจ")
    expect(page).to have_content("- ต้องลาล่วงหน้าอย่างน้อย 3 วัน เป็นลายลักษณ์อักษร ทาง Banana Vacation (http://vacation.bananacoding.com), email หรือ slack")
    expect(page).to have_content("- สำหรับพนักงานทำงานไม่ถึงหนึ่งปี จะลาได้ไม่เกิน 7 วัน")
    expect(page).to have_content("- สำหรับพนักงานเกินหนึ่งปี จะเป็นไปตามอายุงาน และจะเพิ่มปีละ 2 วัน เช่นเข้าทำงานได้ 2 ปีจะได้วันหยุด 11 วัน")
    expect(page).to have_content("- สำหรับพนักงานช่วงทดลองงาน 3 เดือน ลากิจ จะเป็นการลาแบบไม่ได้เงินเดือน ตามจำนวณวันที่ลา เช่นเงินเดือน 10,000 บาท พนักงานต้องทำงานวันละ 8 ชัวโมงต่อวัน 20 วันต่อเดือน คือหัก วันละ 500 บาท")
    expect(page).to have_content("การทำงานที่บ้าน")
    expect(page).to have_content("- ทำงานนอกสถานที่ หรือ ที่บ้าน สามารถทำได้ 2 วันต่อสัปดาห์ ต้องแจ้ง ทาง Banana Vacation (http://vacation.bananacoding.com), email หรือ slack")
    expect(page).to have_content("- ทำงานนอกสถานที่ หรือ ที่บ้าน สามารถทำได้ 2 วันต่อสัปดาห์ ต้องแจ้ง ทาง Banana Vacation (http://vacation.bananacoding.com), email หรือ slack")
    expect(page).to have_content("เพิ่มเติมตามกฎหมายแรงงานที่ http://www.mol.go.th/employee/rihgt_labor%20low")
    expect(page).to have_content("อัพเดทโดย: #{admin.email}")
    expect(page).to have_content("อัพเดทเมื่อ: #{vacation_leave_rules.updated_at.strftime('%d/%m/%Y')}")
  end

  def fill_in_ckeditor(text)
    page.execute_script <<-SCRIPT
        CKEDITOR.instances.editor2.setData('#{text}')
    SCRIPT
  end
end
