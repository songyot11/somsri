class InventoryRepairsController < ApplicationController
	def index
		page = params[:page]
		inventory_repiars = InventoryRepair.all
		inventory_repiars = inventory_repiars.paginate(page: page, per_page: 10)
		inventory_repiars = inventory_repiars.order(updated_at: :desc)

		result = {}
		if page 
			if params[:bootstrap_table].to_s == "1" 
				result = inventory_repiars.as_json({ bootstrap_table: true })
			else 
				result = {
					inventory_repiars: inventory_repiars.as_json({ index: true }) #methods:[:employee, :inventory, :inventory_request]
				}

				if params[:page]
					result[:current_page] = inventory_repiars.current_page
					result[:total_records] = inventory_repiars.total_entries
				end
			end
			render json: result ,status: :ok
		else
			inventory_repiars = InventoryRepair.all
			render json: inventory_repiars, status: :ok
		end
	end

	def show
		inventory_repiars = InventoryRepair.find(params[:id])
		render json: inventory_repiars.as_json(methods:[:manage_inventory_repair]), status: :ok
	end

	def create
		inventory_repiars = InventoryRepair.all
		inventory_repiar = InventoryRepair.new(inventory_repairs_params)
		if inventory_repiar.save
			render json: inventory_repiar, status: :ok
		else
			render json: inventory_repiar.errors.full_messages, status: :ok
		end
	end

	def update
		inventory_repiars = InventoryRepair.find(params[:id])
		inventory_repiars.update(inventory_repairs_params)
		render json: inventory_repiars
	end

	def destroy
		inventory_repiars = InventoryRepair.find(params[:id])
		inventory_repiars.destroy
		render json: { status: :success }
	end

	def repair_notification
		inventory_repiars = InventoryRepair.find(params[:id])
		inventory_repiars.repair_notification?
		inventory_repiars.update(repair_status: :repair_notification)
		render json: inventory_repiars ,status: :ok
	end

	def rejected
		inventory_repiars = InventoryRepair.find(params[:id])
		inventory_repiars.rejected?
		inventory_repiars.update(repair_status: :rejected)
		render json: inventory_repiars ,status: :ok
	end

	def confirm_accept
		inventory_repiars = InventoryRepair.find(params[:id])
		inventory_repiars.confirm_accept?
		inventory_repiars.update(repair_status: :confirm_accept)
		render json: inventory_repiars ,status: :ok
	end

	def sent_repair
		inventory_repiars = InventoryRepair.find(params[:id])
		inventory_repiars.sent_repair?
		inventory_repiars.update(repair_status: :sent_repair)
		render json: inventory_repiars ,status: :ok
	end

	def repairs_completed
		inventory_repiars = InventoryRepair.find(params[:id])
		inventory_repiars.repairs_completed?
		inventory_repiars.update(repair_status: :repairs_completed)
		render json: inventory_repiars ,status: :ok
	end

	def dispatch_to_employees
		inventory_repiars = InventoryRepair.find(params[:id])
		inventory_repiars.dispatch_to_employees?
		inventory_repiars.update(repair_status: :dispatch_to_employees)
		render json: inventory_repiars ,status: :ok
	end

	private
	def inventory_repairs_params
		params.require(:inventory_repairs).permit(:employee_id, :inventory_id, :inventory_request_id, :employee_name, :item_name, :serial_number, :reason, :repair_date, :return_date, :price, :receipt)
	end

end
