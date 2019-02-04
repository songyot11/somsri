class CreateGroupingReportOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :grouping_report_options do |t|
      t.string :name
      t.string :keyword
    end
  end
end
