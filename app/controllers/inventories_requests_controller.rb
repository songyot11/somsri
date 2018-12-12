class InventoriesRequestsController < ApplicationController
	skip_before_action :verify_authenticity_token

	# GET: /inventories
	def index
		# inventories_requests = InventoryRequests.all
		# render json: inventories_requests. status: :ok
		# render json: inventories_requests.as_json(methods: [:employee, :inventory]), status: :ok

		inventories_requests = get_inventories_request(params[:page])
		if params[:page] && inventories_requests.total_pages < inventories_requests.current_page
			inventories_requests = get_inventories_request()
		end

		result = {}
		if params[:bootstrap_table].to_s == "1" 
			result = inventories_requests.as_json({ bootstrap_table: true })
		else 
			result = {
				inventories_requests: inventories_requests.as_json({ index: true })
			}

			if params[:page]
				result[:current_page] = inventories_requests.current_page
				result[:total_records] = inventories_requests.total_entries
			end
		end
		render json: result, status: :ok
	end

	# GET: /inventories/:id
	def show 
		inventories_request = InventoryRequest.find(params[:id])
		render json: inventories_request, status: :ok
	end

	def new

	end

	#POST: /inventories_requests
	def create 
		inventories = InventoryRequest.all
		inventory = InventoryRequest.new(inventory_params)
		if inventory.save
			render json: inventory, status: :ok
		else
			render json: inventory.errors.full_messages, status: :ok
		end
	end

	def edit

	end
	# PUT: /inventories_requests/:id
	def update
		inventory = InventoryRequest.find(params[:id])
		inventory.update(inventory_params)
		render json: inventory
	end

	# DELETE: /inventories_requests/:id
	def destroy
		inventory = InventoryRequest.find(params[:id])
		inventory.destroy
		render json: { status: :success }
	end

	# PUT: inventories_requests/:id/approve // Member
	# PUT: inventories_requests/approve    // Collection
	#[:approved, :rejected ,:pending, :accept, :purchasing, :done, :assinged]
	def approve
		inventory = InventoryRequest.first
		inventory.approve?
		inventory.update(inventory_status: :approve)
	end

	def reject
		inventory = InventoryRequest.first
		inventory.reject?
		inventory.update(inventory_status: :reject)
	end

	def pending
		inventory = InventoryRequest.first
		inventory.pending?
		inventory.update(inventory_status: :pending)
	end

	def accept
		inventory = InventoryRequest.first
		inventory.accept?
		inventory.update(inventory_status: :accept)
	end

	def purchasing
		inventory = InventoryRequest.first
		inventory.purchasing?
		inventory.update(inventory_status: :purchasing)
	end

	def done
		inventory = InventoryRequest.first
		inventory.done?
		inventory.update(inventory_status: :done)
	end

	def assinged
		inventory = InventoryRequest.first
		inventory.assinged?
		inventory.update(inventory_status: :assinged)
	end

	private

	def inventory_params
		params.require(:inventory).permit(:user_name, :item_name, :description, :price, :request_date)
	end

	def get_inventories_request(page)
		inventories = InventoryRequest.all
		inventories = inventories.paginate(page: page, per_page: 10)
		return inventories.to_a
	end
end
