class AddLeaveToEmployee < ActiveRecord::Migration[5.0]
	def change
		add_column :employees, :sick_leave_maximum_days_per_year , :integer
		add_column :employees, :personal_leave_maximum_days_per_year , :integer
		add_column :employees, :switching_day_maximum_days_per_year , :integer
		add_column :employees, :work_at_home_maximum_days_per_week , :integer
		add_column :employees, :switching_day_allow , :boolean
		add_column :employees, :work_at_home_allow , :boolean
	end
  end