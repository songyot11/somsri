class ManageInventoriesRequestsController < ApplicationController
	# ManageInventoryRequestsController
		# POST /manage_inventory_requests
		def create
			invetory_request = InventoryRequest.find(params[:inventories_request_id])
			manage = invetory_request.manage_inventory_requests.new(manage_params)
			if manage.save
				render json: manage, status: :ok
			else
				render json: manage.errors.full_messages, status: :ok
			end
		end

		# PUT /manage_inventory_requests/:id
		def update
			inventory_rquest = InventoryRequest.find(params[:inventories_request_id])
			# manage = ManageInventoryRequest.find(params[:id])git 
			manage = inventory_rquest.manage_inventory_requests.update(manage_params)
			render json: manage , status: :ok
		end

		private

		def manage_params
			params.require(:manage_inventories_requests).permit(
				:step, 
				:save_by,
				:accept, 
				:save_by_step2, 
				:date_purchase,
				:date_send,
				:price,
				:save_by_step3,
				:get_date,
				:buy_slip,
				:end_warranty,
				:save_by_step4,
				:send_to_employee_name,
				:send_to_employee_id,
				:save_by_step5
			)
		end
end
