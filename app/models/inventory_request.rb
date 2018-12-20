class InventoryRequest < ApplicationRecord
	has_many :manage_inventory_requests
	enum inventory_status: [:approved, :rejected ,:pending, :accept, :purchasing, :done, :assigned]
	def manage_inventory
		step1 = manage_inventory_requests.find_by(step: 1)
		step2 = manage_inventory_requests.find_by(step: 2)
		step3 = manage_inventory_requests.find_by(step: 3)
		step4 = manage_inventory_requests.find_by(step: 4)
		step5 = manage_inventory_requests.find_by(step: 5)
		step = manage_inventory_requests
		{
			step_id: step[0]&.id,
			step: step[0]&.step,
			"step1": {
				accept: step1&.accept,
				save_by: step1&.save_by
			},
			"step2": {
				date_purchase: step2&.date_purchase ,
	   		date_send: step2&.date_send,
    		price: step2&.price,
    		save_by: step2&.save_by_step2
			},
			"step3": {
				get_date: step3&.get_date,
	    	buy_slip: step3&.buy_slip,
	    	end_warranty: step3&.end_warranty,
	   		save_by: step3&.save_by_step3
			}, 
			"step4": {
				send_to_employee_name: step4&.send_to_employee_name,
	    	send_to_employee_id: step4&.send_to_employee_id,
	   		save_by: step4&.save_by_step4
			},
			"step5": {
				save_by: step4&.save_by_step5
			}
		}
	end
end
