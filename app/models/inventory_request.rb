class InventoryRequest < ApplicationRecord
	belongs_to :inventory
	enum inventory_status: [:approved, :rejected ,:pending, :accept, :purchasing, :done, :assigned]

	# def inventory_name
	# 	self.inventory.item_name
	# end
end
