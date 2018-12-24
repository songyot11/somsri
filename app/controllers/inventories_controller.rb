class InventoriesController < ApplicationController
	skip_before_action :verify_authenticity_token

	# GET: /inventories
	def index
		page = params[:page]
		search = params[:search_keyword]
		start_date_purchase = DateTime.parse(params[:start_date_purchase]).beginning_of_day if isDate(params[:start_date_purchase])
    end_date_purchase = DateTime.parse(params[:end_date_purchase]).end_of_day if isDate(params[:end_date_purchase])
    start_date_add = DateTime.parse(params[:start_date_add]).beginning_of_day if isDate(params[:start_date_add])
    end_date_add = DateTime.parse(params[:end_date_add]).end_of_day if isDate(params[:end_date_add])
    check_box = params[:check_box]
    puts check_box
		
		# inventories = get_inventories(params[:search_keyword],start_date_purchase,end_date_purchase,params[:page])
		# if params[:page] && inventories.total_pages < inventories.current_page
		# 	inventories = get_inventories(params[:search_keyword],start_date_purchase,end_date_purchase)
		# end

		inventories = Inventory.all
    inventories = inventories.search(search) if search.present?

    if check_box 
    	inventories = inventories.joins(:category).where(categories: { category_id: check_box })
    end

		data_field = Inventory.arel_table[:date_purchase]
    inventories = qry_date_range(inventories, data_field, start_date_purchase, end_date_purchase)
    inventories = qry_date_range(inventories, data_field, start_date_add, end_date_add)
    inventories = inventories.paginate(page: page, per_page: 10)

		result = {}
		if params[:bootstrap_table].to_s == "1" 
			result = inventories.as_json({ bootstrap_table: true })
		else 
			result = {
				inventories: inventories.as_json(methods:[:categories])
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
		render json: inventory.as_json(methods:[:categories]), status: :ok
	end

	def new

	end

	#POST: /inventories
	def create 

		#i = Inventory.find(1);
    #e = i.employee

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

	def get_inventories(search_keyword,start_date_purchase,end_date_purchase,page)
		inventories = Inventory.all.search(search_keyword) #if search_keyword.present?
		data_field = Inventory.arel_table[:created_at]
    inventories = qry_date_range(inventories, data_field, start_date_purchase, end_date_purchase)

    # qry_invoices = qry_invoices.order("#{sort} #{order}")
		inventories = inventories.paginate(page: page, per_page: 10)
		return inventories.to_a
	end
end
