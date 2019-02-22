class InventoryRepair < ApplicationRecord
	belongs_to :employee
	belongs_to :inventory
	belongs_to :inventory_request
	has_one :manage_inventory_repair
	enum repair_status: [:repair_notification, :confirm_accept, :rejected ,:sent_repair, :repairs_completed, :dispatch_to_employees]
end
