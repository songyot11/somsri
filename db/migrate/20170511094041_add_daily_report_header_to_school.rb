class AddDailyReportHeaderToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :daily_report_header, :text
  end
end
