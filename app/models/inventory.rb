class Inventory < ApplicationRecord
	# has_many :inventory_request
	belongs_to :employee
	validates :item_name, presence: true	

	def self.search(keyword)
		if keyword.present?
      left_outer_joins(:employee).where(
        "CAST(inventories.id AS TEXT) LIKE :search OR
        item_name LIKE :search OR
        serial_number LIKE :search OR
        model LIKE :search OR
        CAST(inventories.date_purchase AS TEXT) LIKE :search OR
        employees.first_name LIKE :search OR 
        employees.last_name LIKE :search OR
        employees.first_name_thai LIKE :search OR
        employees.last_name_thai LIKE :search
       ",
        search: "%#{keyword}%")
    else 
			self.all
		end
	end
end
