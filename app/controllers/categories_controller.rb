class CategoriesController < ApplicationController

	#POST /categories
	def create
		inventories = Inventory.find(params[:inventory_id])
		category = inventories.build_category(categories_params)
		if category.save
			render json: category, status: :ok
		else
			render json: category.errors.full_messages, status: :ok
		end
	end

	#PUT /categories/:id
	def update
		inventories = Inventory.find(params[:inventory_id])
		category = inventories.category.update(categories_params)
		render json: category, status: :ok
	end

	private
	def categories_params
		params.require(:categories).permit(:category_id, :category_name, :category_barcode)
	end
end
