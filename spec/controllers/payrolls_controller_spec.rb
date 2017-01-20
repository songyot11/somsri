describe PayrollsController do
  it "should return santang" do
    ctrl = PayrollsController.new
    expect(ctrl.send(:satang, 2000.00)).to eq("00")
    expect(ctrl.send(:satang, 20.01)).to eq("01")
    expect(ctrl.send(:satang, 2000.50)).to eq("50")
  end

  it "should generate pdf from template" do
    ctrl = PayrollsController.new
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
end
