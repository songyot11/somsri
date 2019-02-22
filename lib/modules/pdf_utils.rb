module PdfUtils
  def generate_pdf(template, datas, tmp_dir)
    FileUtils.mkdir_p "#{tmp_dir}" unless File.directory?("#{tmp_dir}")
    result_file = ""
    datas.each do |data|
      data_file_tmp = generate_pdf_file_name(tmp_dir)
      result_file_tmp = generate_pdf_file_name(tmp_dir)
      merged_file_tmp = generate_pdf_file_name(tmp_dir)

      yield data_file_tmp, data
      PDF::Toolkit.pdftk(template, "background", data_file_tmp, "output", result_file_tmp)

      # merge
      if !result_file.blank?
        PDF::Toolkit.pdftk(result_file, result_file_tmp, "cat", "output", merged_file_tmp)
        result_file = merged_file_tmp
      else
        result_file = result_file_tmp
      end
    end
    return result_file
  end

  def generate_pdf_file_name(dir)
    "#{dir}/pdf-#{random_string()}.pdf"
  end

  def random_string
    (0...32).map { (65 + rand(26)).chr }.join
  end
end
