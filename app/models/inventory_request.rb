class InventoryRequest < ApplicationRecord
	has_one :manage_inventory_request
	belongs_to :employee
	enum inventory_status: [:wait, :approved, :rejected ,:pending, :accept, :purchasing, :done, :assigned ,:delete_inventory]
	def manage_inventory

		step = manage_inventory_request
		{
			step_id: step&.id,
			step: step&.step,
			inventory_id: step&.inventory_id,
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

	def self.search(keyword)
		if keyword.present?
      left_outer_joins(:employee).where(
        "CAST(inventory_requests.id AS TEXT) LIKE :search OR
        item_name LIKE :search OR
        user_name LIKE :search OR
        description LIKE :search OR
        CAST(inventory_requests.request_date AS TEXT) LIKE :search OR
        employees.first_name LIKE :search OR 
        employees.last_name LIKE :search OR
        employees.first_name_thai LIKE :search OR
        employees.last_name_thai LIKE :search
       ",
        search: "%#{keyword}%")
    else 
			self.all
		end
	end
end
