class MergeUsersDataToEmployeeTable < ActiveRecord::Migration[5.0]
  def up
		sql = "Select * from users"
		records_array = ActiveRecord::Base.connection.execute(sql)

		sql_roles = "Select * from users_roles join roles on users_roles.role_id = roles.id"
		users_roles_array = ActiveRecord::Base.connection.execute(sql_roles)

		records_array.each do |user|
			users_roles_array.each do |roles|
				if user["id"].present?
					if user["id"] == roles["user_id"]
						user["id"] = nil
						tax_reduction = {
							child: nil,
							cripple_alimony: nil,
							expenses: nil,
							father_alimony: nil,
							mother_alimony: nil,
							no_income_spouse: nil,
							spouse_father_alimony: nil,
							spouse_mother_alimony: nil
						}
						employee = User.new(user)
						if user["email"] == employee.email
							role = roles["name"]
							employee.add_role(role);
						end
						employee.save(validate: false)
						tax_reduction_build = employee.build_tax_reduction(tax_reduction)
						tax_reduction_build.save
					end
				end
			end
		end
  end

  def down
  	
  end
end
