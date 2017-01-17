class AddEffectiveDateToPayRoll < ActiveRecord::Migration[5.0]

  def up
    add_column :payrolls, :effective_date, :datetime
    Payroll.find_each do |pr|
      if !pr.effective_date
        pr.effective_date = pr.created_at.end_of_month()
        pr.save!
      end
    end
    change_column :payrolls, :effective_date, :datetime, null: false
  end

  def down
    remove_column :payrolls, :effective_date
  end

end
