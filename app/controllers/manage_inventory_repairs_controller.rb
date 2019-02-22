class ManageInventoryRepairsController < ApplicationController
	def create
		invetory_repair = InventoryRepair.find(params[:inventory_repair_id])
		manage = invetory_repair.build_manage_inventory_repair(manage_params) # has_one use build
		if manage.save
			render json: manage, status: :ok
		else
			render json: manage.errors.full_messages, status: :ok
		end
	end

	def update
		invetory_repair = InventoryRepair.find(params[:inventory_repair_id])
		manage = invetory_repair.manage_inventory_repair.update(manage_params)
		render json: manage , status: :ok
	end

	private
	def manage_params
		params.require(:manage_inventory_repair).permit(
    	:step,
    	:step1_save_by,
    	:repair_date,
    	:supplier_name,
    	:appointment_date,
    	:step2_save_by,
    	:return_date,
			:price,
    	:receipt,
    	:step3_save_by,
    	:employee_id,
    	:step4_save_by
		)
	end
end
