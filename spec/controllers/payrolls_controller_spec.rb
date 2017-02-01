describe PayrollsController do

  let(:ctrl) { PayrollsController.new }

  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }

  let(:user) { User.make!({ school_id: school.id }) }

  let(:employees) do
    [
      Employee.make!({
        school_id: school.id,
        first_name: "Somsri",
        middle_name: "Is",
        last_name: "Appname",
        prefix: "Mrs.",
        first_name_thai: "สมศรี",
        last_name_thai: "เป็นชื่อแอพ",
        prefix_thai: "นาง",
        salary: 50000
      }),
      Employee.make!({
        school_id: school.id,
        first_name: "Somchit",
        middle_name: "Is",
        last_name: "Boxing",
        prefix: "Mr",
        first_name_thai: "สมจิตร",
        last_name_thai: "เป็นนักมวย",
        prefix_thai: "นาย",
        salary: 20000
      })
    ]
  end

  let(:payrolls) do
    [
      Payroll.make!({
        employee_id: employees[0].id,
        salary: 50000,
        tax: 100,
        advance_payment: 2000,
        allowance: 3000,
        social_insurance: 750,
        effective_date: DateTime.now.next_month(1)
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 20000,
        tax: 1000,
        position_allowance: 10000,
        fee_etc: 200,
        social_insurance: 1000,
        effective_date: DateTime.now.next_month(1)
      }),

      Payroll.make!({
        employee_id: employees[0].id,
        salary: 5000,
        tax: 10,
        advance_payment: 200,
        allowance: 300,
        social_insurance: 750,
        effective_date: DateTime.now
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 2000,
        tax: 100,
        position_allowance: 1000,
        fee_etc: 20,
        social_insurance: 750,
        effective_date: DateTime.now
      }),

      Payroll.make!({
        employee_id: employees[0].id,
        salary: 500,
        tax: 1,
        advance_payment: 20,
        allowance: 30,
        effective_date: DateTime.new(2016, 8, 1)
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 200,
        tax: 10,
        position_allowance: 100,
        fee_etc: 2,
        effective_date: DateTime.new(2016, 8, 1)
      })
    ]
  end

  before do
    payrolls
    sign_in user
  end

  it "should return santang" do
    expect(ctrl.send(:satang, 2000.00)).to eq("00")
    expect(ctrl.send(:satang, 20.01)).to eq("01")
    expect(ctrl.send(:satang, 2000.50)).to eq("50")
  end

  it "should generate pdf from template" do
    template = "#{Rails.root}/public/sps1-2.pdf"

    tmp_dir = "#{Rails.root}/tmp/#{ctrl.random_string}"
    output_file = ctrl.generate_pdf_file_name('#{Rails.root}/tmp/sps1')
    FileUtils.mkdir_p "#{Rails.root}/tmp/sps1" unless File.directory?("#{Rails.root}/tmp/sps1")

    header_pdfs = ctrl.generate_pdf(template, ["HEADERRR", "กกกกกกกกกกกกก"], tmp_dir) do |file, data|
      Prawn::Document.generate(file, :page_layout => :landscape) do
        font("#{Rails.root}/public/fonts/THSarabunNew.ttf") do
          text_box data, :at => [20, 500], :size => 28
        end
      end
    end

    reader = PDF::Reader.new(header_pdfs)
    expect(reader.page_count).to eq(2)

    expect(reader.pages[0].text).to have_content("HEADERRR")
    expect(reader.pages[0].text).to have_content("สปส.1-10")

    expect(reader.pages[1].text).to have_content("กกกกกกกกกกกกก")
    expect(reader.pages[1].text).to have_content("สปส.1-10")

    FileUtils.rm_rf tmp_dir # remove all tmp
  end

  it "should generate social insurance in pdf format" do
    date_time = payrolls[0].effective_date
    get :social_insurance_pdf, effective_date: date_time

    temp_pdf = Tempfile.new('pdf')
    temp_pdf << response.body.force_encoding('UTF-8')
    reader = PDF::Reader.new(temp_pdf)
    pdf_text = reader.pages.map(&:text)

    expect(response.header["Content-Type"]).to eq "application/pdf"
    expect(pdf_text).to have_content "สปส.1-10"
    expect(pdf_text).to have_content "7000"
    expect(pdf_text).to have_content "1750"
    expect(pdf_text).to have_content "3500"
    expect(pdf_text).to have_content "1000"
    expect(pdf_text).to have_content "750"
  end

  it "should display error text when generate social insurance pdf with no social_insurance in every payroll" do
    get :social_insurance_pdf, effective_date: payrolls[4].effective_date
    expect(response.body).to have_content "ไม่มีพนักงานที่ต้องเสียค่าประกันสังคม"
  end
end
