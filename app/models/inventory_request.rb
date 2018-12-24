class InventoryRequest < ApplicationRecord
	has_one :manage_inventory_request
	enum inventory_status: [:approved, :rejected ,:pending, :accept, :purchasing, :done, :assigned]
	def manage_inventory

		step = manage_inventory_request
		{
			step_id: step&.id,
			step: step&.step,
			"step1": {
				accept: step&.accept,
				save_by: step&.save_by
			},
			"step2": {
				date_purchase: step&.date_purchase ,
	   		date_send: step&.date_send,
    		price: step&.price,
    		save_by: step&.save_by_step2
			},
			"step3": {
				get_date: step&.get_date,
	    	buy_slip: step&.buy_slip,
	    	end_warranty: step&.end_warranty,
	   		save_by: step&.save_by_step3
			}, 
			"step4": {
				send_to_employee_name: step&.send_to_employee_name,
	    	send_to_employee_id: step&.send_to_employee_id,
	   		save_by: step&.save_by_step4
			},
			"step5": {
				save_by: step&.save_by_step5
			}
		}
	end
end
