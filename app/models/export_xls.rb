class ExportXls
  def self.export_expenses_xls(results, total_all_price, date_time_string)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet(name: 'Expense')

    #header
    sheet1.row(0)[0] = School.first.name
    sheet1.row(0).set_format(0, bold)
    sheet1.row(1)[0] = "#{I18n.t('expense_list')} : #{date_time_string}"
    sheet1.row(1).set_format(0, bold)

    sheet1.row(2)[0] = I18n.t('date1')
    sheet1.row(2)[1] = I18n.t('buy_slip')
    sheet1.row(2)[2] = I18n.t('expense_detail')
    sheet1.row(2)[3] = I18n.t('total_cost')
    sheet1.row(2).set_format(0, bold)
    sheet1.row(2).set_format(1, bold)
    sheet1.row(2).set_format(2, bold)
    sheet1.row(2).set_format(3, bold_right)


    results.each_with_index do |result, i|
      sheet1.insert_row (i + 3), [
        I18n.l(result.effective_date, format: '%d/%m/%Y'),
        result.expenses_id.present? ? result.expenses_id : "-",
        result.detail.present? ? result.detail : "-",
        result.total_cost.present? ? helper.number_with_precision(result.total_cost, precision: 2, delimiter: ',') : "-"
      ]
      sheet1.row(i + 3).set_format(3, right)
    end

    sheet1.row(results.length + 3)[2] = I18n.t('total_price')
    sheet1.row(results.length + 3).set_format(2, bold_right)
    sheet1.row(results.length + 3)[3] = helper.number_with_precision(total_all_price, precision: 2, delimiter: ',')
    sheet1.row(results.length + 3).set_format(3, bold_right)

    return write_to_io(book)
  end

  def self.export_expenses_by_payment_xls(results, total_all_price, date_time_string)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet(name: 'Payment')

    #header
    sheet1.row(0)[0] = School.first.name
    sheet1.row(0).set_format(0, bold)
    sheet1.row(1)[0] = "#{I18n.t('expenses_payment_report')} : #{date_time_string}"
    sheet1.row(1).set_format(0, bold)

    sheet1.row(2)[0] = I18n.t('item')
    sheet1.row(2)[1] = I18n.t('amount')
    sheet1.row(2).set_format(0, bold)
    sheet1.row(2).set_format(1, bold_right)

    results.each_with_index do |result, i|
      sheet1.insert_row (i + 3), [
        result[:payment_method].present? ? result[:payment_method] : "-",
        result[:total_cost].present? ? helper.number_with_precision(result[:total_cost], precision: 2, delimiter: ',') : "-"
      ]
      sheet1.row(i + 3).set_format(1, right)
    end

    sheet1.row(results.length + 3)[0] = I18n.t('total_price')
    sheet1.row(results.length + 3).set_format(0, bold_right)
    sheet1.row(results.length + 3)[1] = helper.number_with_precision(total_all_price, precision: 2, delimiter: ',')
    sheet1.row(results.length + 3).set_format(1, bold_right)

    return write_to_io(book)
  end

  def self.export_by_tag_xls(results, expense_tags, total_cost, other_cost, lv_max, date_time_string)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet(name: 'Category')

    #header
    sheet1.row(0)[0] = School.first.name
    sheet1.row(0).set_format(0, bold)
    sheet1.row(1)[0] = "#{I18n.t('expenses_classification_report')} : #{date_time_string}"
    sheet1.row(1).set_format(0, bold)

    sheet1.row(2)[0] = I18n.t('item')
    sheet1.row(2)[lv_max] = I18n.t('amount')
    sheet1.row(2).set_format(0, bold)
    sheet1.row(2).set_format(lv_max, bold_right)

    results.each_with_index do |result, i|
      sheet1.row(i + 3)[lv_max - result[:lv]] = (expense_tags.find{|et| et.id == result[:id]}).name
      sheet1.row(i + 3)[lv_max] = helper.number_with_precision(result[:cost], precision: 2, delimiter: ',')
      sheet1.row(i + 3).set_format(lv_max, right)
    end

    sheet1.row(results.length + 3)[0] = I18n.t('other_cost')
    sheet1.row(results.length + 3).set_format(0, bold)
    sheet1.row(results.length + 3)[lv_max] = helper.number_with_precision(other_cost, precision: 2, delimiter: ',')
    sheet1.row(results.length + 3).set_format(lv_max, right)

    sheet1.row(results.length + 4)[0] = I18n.t('total_price')
    sheet1.row(results.length + 4).set_format(0, bold_right)
    sheet1.row(results.length + 4)[lv_max] = helper.number_with_precision(total_cost, precision: 2, delimiter: ',')
    sheet1.row(results.length + 4).set_format(lv_max, bold_right)

    return write_to_io(book)
  end

  def self.write_to_io(book)
    buffer = StringIO.new
    book.write(buffer)
    buffer.rewind
    return buffer
  end

  def self.bold
    Spreadsheet::Format.new(weight: :bold)
  end

  def self.right
    Spreadsheet::Format.new(horizontal_align: :right)
  end

  def self.bold_right
    Spreadsheet::Format.new(weight: :bold, horizontal_align: :right)
  end

  private
  def self.helper
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end
end
