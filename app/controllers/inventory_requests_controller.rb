class InventoryRequestsController < ApplicationController
	skip_before_action :verify_authenticity_token
	load_and_authorize_resource
	# GET: /inventories
	def index
		search = params[:search_keyword]
		employee_id = params[:employee_id]
		start_request_date = DateTime.parse(params[:start_request_date]).beginning_of_day if isDate(params[:start_request_date])
    end_request_date = DateTime.parse(params[:end_request_date]).end_of_day if isDate(params[:end_request_date])
    start_date_purchasing = DateTime.parse(params[:start_date_purchasing]).beginning_of_day if isDate(params[:start_date_purchasing])
    end_date_purchasing = DateTime.parse(params[:end_date_purchasing]).end_of_day if isDate(params[:end_date_purchasing])
    check_box = params[:check_box]
		# @inventory_requests
		# inventories_requests = InventoryRequests.all
		# render json: inventories_requests. status: :ok
		# render json: inventories_requests.as_json(methods: [:employee, :inventory]), status: :ok

		if check_box 
    	@inventory_requests = @inventory_requests.where(inventory_requests: { inventory_status: check_box })
    end

		data_field = InventoryRequest.arel_table[:request_date]
    @inventory_requests = qry_date_range(@inventory_requests, data_field, start_request_date, end_request_date)
    @inventory_requests = qry_date_range(@inventory_requests, data_field, start_date_purchasing, end_date_purchasing)
		
		@inventory_requests = @inventory_requests.filterByEmployeeId(employee_id) if employee_id.present?
		@inventory_requests = @inventory_requests.search(search) if search.present?

		@inventory_requests = @inventory_requests.paginate(page: params[:page], per_page: 10)
		@inventory_requests = @inventory_requests.order(updated_at: :desc)
		

		

		# if params[:page] && inventories_requests.total_pages < inventories_requests.current_page
		# 	inventories_requests = get_inventories_request()
		# end

		# if current_user.has_role? :admin
		# 	inventories_requests = InventoryRequests.all
		# 	inventories_requests = inventories_requests.where.not(inventories_requests_status: :delete_inventory)
		# elsif current_user.has_role? :employee
		# 	inventories_requests = current_user.inventory_requests
		# 	inventories_requests = inventories_requests
		# end

		result = {}
		if params[:bootstrap_table].to_s == "1" 
			result = @inventory_requests.as_json({ bootstrap_table: true })
		else 
			result = {
				inventories_requests: @inventory_requests.as_json(methods:[:inventory])
			}

			if params[:page]
				result[:current_page] = @inventory_requests.current_page
				result[:total_records] = @inventory_requests.total_entries
			end
		end

		render json: result, status: :ok
	end

	# GET: /inventories_request/:id
	def show 
		inventories_request = InventoryRequest.find(params[:id])
		
		render json: inventories_request.as_json(methods:[:manage_inventory, :inventory]), status: :ok
	end

	def new

	end

	#POST: /inventories_requests
	def create 
		inventories_request = InventoryRequest.all
		inventories = InventoryRequest.new(inventory_params)
		if inventories.save
			render json: inventories, status: :ok
		else
			render json: inventories.errors.full_messages, status: :ok
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
		inventory = InventoryRequest.find(params[:id])
		inventory.approved?
		inventory.update(inventory_status: :approved)
		render json: inventory ,status: :ok
	end

	def reject
		inventory = InventoryRequest.find(params[:id])
		inventory.rejected?
		inventory.update(inventory_status: :rejected)
		render json: inventory ,status: :ok
	end

	def pending
		inventory = InventoryRequest.find(params[:id])
		inventory.pending?
		inventory.update(inventory_status: :pending)
		render json: inventory ,status: :ok
	end

	def accept
		inventory = InventoryRequest.find(params[:id])
		inventory.accept?
		inventory.update(inventory_status: :accept)
		render json: inventory ,status: :ok
	end

	def purchasing
		inventory = InventoryRequest.find(params[:id])
		inventory.purchasing?
		inventory.update(inventory_status: :purchasing)
		render json: inventory ,status: :ok
	end

	def done
		inventory = InventoryRequest.find(params[:id])
		inventory.done?
		inventory.update(inventory_status: :done)
		render json: inventory ,status: :ok
	end

	def assigned
		inventory = InventoryRequest.find(params[:id])
		inventory.assigned?
		inventory.update(inventory_status: :assigned)
		render json: inventory ,status: :ok
	end

  def delete_inventory
  	inventory = InventoryRequest.find(params[:id])
		inventory.delete_inventory?
		inventory.update(inventory_status: :delete_inventory)
		render json: inventory ,status: :ok
  end

  def wait
  	inventory = InventoryRequest.find(params[:id])
		inventory.wait?
		inventory.update(inventory_status: :wait)
		render json: inventory ,status: :ok
  end

  def repair
  	inventory = InventoryRequest.find(params[:id])
  	inventory.repair?
  	inventory.update(inventory_status: :repair)
  	render json: inventory, status: :ok
  end


	private

	def inventory_params
		params.require(:inventories_request).permit(:user_name, :item_name, :description, :price, :request_date, :comment , :employee_id, :inventory_id, :return_date, :request_count, :request_type, :define_return_date)
	end

	def get_inventories_request(page)
		@inventory_requests = @inventory_requests.paginate(page: page, per_page: 10)
	end
end
