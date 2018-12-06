class InventoriesController < ApplicationController
	skip_before_action :verify_authenticity_token

	# GET: /inventories
	def index
		inventories = Inventory.all
		render json: inventories.as_json(methods: [:inventoy_requests]), status: :ok
	end

	# GET: /inventories/:id
	def show 

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
		inventory.destory
		render json: { status: :success }
	end

	private

	def inventory_params
		params.require(:inventory).permit(:item_name, :serial_number, :model, :description, :price, :date_purchase, :category, :date_add)
	end
end
