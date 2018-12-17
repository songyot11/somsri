class InventoriesController < ApplicationController
	skip_before_action :verify_authenticity_token

	# GET: /inventories
	def index
		page = params[:page]
		inventories = get_inventories(params[:page])
		if params[:page] && inventories.total_pages < inventories.current_page
			inventories = get_inventories()
		end

		result = {}
		if params[:bootstrap_table].to_s == "1" 
			result = inventories.as_json({ bootstrap_table: true })
		else 
			result = {
				inventories: inventories.as_json({ index: true })
			}

			if params[:page]
				result[:current_page] = inventories.current_page
				result[:total_records] = inventories.total_entries
			end
		end
		render json: result, status: :ok
	end

	# GET: /inventories/:id
	def show 
		inventory = Inventory.find(params[:id])
		render json: inventory, status: :ok
	end

	def new

	end

	#POST: /inventories
	def create 
		inventories = Inventory.all
		inventory = Inventory.new(inventory_params)
		if inventory.save
			render json: inventory, status: :ok
		else
			render json: inventory.errors.full_messages, status: :ok
		end
	end

	def edit

	end
	# PUT: /inventories/:id
	def update
		inventory = Inventory.find(params[:id])
		inventory.update(inventory_params)
		render json: inventory
	end

	# DELETE: /inventories/:id
	def destroy
		inventory = Inventory.find(params[:id])
		inventory.destroy
		render json: { status: :success }
	end

	private

	def inventory_params
		params.require(:inventory).permit(:item_name, :serial_number, :model, :description, :price, :date_purchase, :category, :category_barcode, :date_add, :end_warranty ,:employee_id)
	end

	def get_inventories(page)
		inventories = Inventory.all
		inventories = inventories.paginate(page: page, per_page: 10)
		return inventories.to_a
	end
end
