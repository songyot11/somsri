class InventoriesController < ApplicationController
	skip_before_action :verify_authenticity_token

	# GET: /inventories
	def index
		page = params[:page]
		inventories = Inventory.all
		# inventories = inventories.paginate(page: page, per_page: Inventory.count)
		# inventories = get_inventories(params[:page])
		# if params[:page] && inventories.total_pages < inventories.current_page
		# 	inventories = get_inventories()
		# end

		# if params[:limit] && params[:offset]
		# 	per_page = params[:limit].to_i
		# 	page = (params[:offset].to_i.per_page) + 1
		# respond_to do |format|
		# 	format.json do
		# 		result = {
		# 			inventories: inventories.paginate(page: page, per_page: Inventory.count)
		# 		}
		# 		if page
		# 			result[:current_page] = result[:inventories].current_page
		# 			result[:total_records] = result[:inventories].total_records
		# 		end
		# 		render json: result, status: :ok
		# 	end
		# end

		# result = {
		# 	inventories: inventories.paginate(page: params[:page], per_page: Inventory.count)
		# }
		# end

		# if params[:page] 
		# 	result[:current_page] = result[:inventories].current_page
		# 	result[:total_records] = result[:inventories].total_records
		# end

		# # result = {
		# 	row: inventories.as_json({ index: true}),
		# 	total: inventories.count
		# }

		result = {}
		if params[:bootstrap_table].to_s == "1" 
			# result = inventories.as_json({ bootstrap_table: true })
		else 
			result = {
				inventories: inventories.as_json({ index: true })
			}

			if params[:page]
				result[:current_page] = result[:inventories].current_page
				result[:total_records] = result[:inventories].total_records
			end
		end
		render json: result, status: :ok
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

	def get_inventories(page)
		inventories = Inventory.all
		inventories = inventories.paginate(page: page, per_page: Inventory.count)
		return inventories.to_a
	end
end
