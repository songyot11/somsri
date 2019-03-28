class CreateVacationSettings < ActiveRecord::Migration[5.0]
	def change
	  create_table :vacation_settings do |t|
		t.belongs_to :school, index: true
		t.integer :sick_leave_maximum_days_per_year, default: 30
		t.boolean :sick_leave_require_approval
		t.boolean :sick_leave_require_medical_certificate
		t.string  :sick_leave_note
		t.integer :personal_leave_maximum_days_per_year, default: 15
		t.integer :personal_leave_submission_days, default: 2
		t.boolean :personal_leave_allow_morning, default: true
		t.boolean :personal_leave_allow_afternoon, default: true
		t.string  :personal_leave_note
		t.boolean :switching_day_allow, default: true
		t.integer :switching_day_maximum_days_per_year, default: 15
		t.boolean :switching_day_require_approval, default: true
		t.integer :switching_day_submission_days, default: 2
		t.string  :switching_day_note
		t.boolean :work_at_home_allow, default: true
		t.integer :work_at_home_maximum_days_per_week, default: 2
		t.boolean :work_at_home_require_approval
		t.integer :work_at_home_submission_days
		t.string  :work_at_home_note
	  end
	end
  end