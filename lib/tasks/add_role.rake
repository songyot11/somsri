namespace :add_role do
	task employee: :environment do 
	users = User.all
		for user in users do
			check = true
			if user.roles.count > 0
				if user.roles.collect { |r| r.name }
					roles = user.roles.collect { |r| r.name }
					roles.each do |role|
						if role == "employee"
							check = false
						end
					end
				end

				if check
					user.add_role("employee")
				end
			else 
				user.add_role("employee")
			end
		end
	end
end
