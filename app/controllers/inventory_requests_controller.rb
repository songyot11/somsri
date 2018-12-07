class InventoryRequestsController < ApplicationController
	skip_before_action :verify_authenticity_token

	# GET: /inventories
	def index
		inventories_requests = InventoryRequests.all
		render json: inventories_requests.as_json(methods: [:uesr, :inventory]), status: :ok
	end

	# GET: /inventories/:id
	def show 

	end

	def new

	end

	#POST: /inventories_request
	def create 
		inventories = InventoryRequests.all
		render json: inventories, status: :ok
	end

	def edit

	end
	# PUT: /inventories_request/:id
	def update
		inventory = InventoryRequests.find(params[:id])
		inventory.update(inventory_params)

		render json: inventory
	end

	# DELETE: /inventories_request/:id
	def destroy
		inventory = InventoryRequests.find(params[:id])
		inventory.destory
		render json: { status: :success }
	end

	# PUT: inventories_request/:id/approve // Member
	# PUT: inventories_request/approve    // Collection
	def approve
		inventory = InventoryRequests.first
		inventory.approve?
		inventory.update(inventory_status: :approve)
	end

	def pending
		inventory = InventoryRequests.first
		inventory.pending?
		inventory.update(inventory_status: :pending)
	end

	def reject
		inventory = InventoryRequests.first
		inventory.reject?
		inventory.update(inventory_status: :reject)
	end

	def done
		inventory = InventoryRequests.first
		inventory.done?
		inventory.update(inventory_status: :done)
	end

	private

	def inventory_params
		params.require(:inventory).permit(:user_id, :inventory_id, :item_name, :description, :price, :request_date)
	end
end
