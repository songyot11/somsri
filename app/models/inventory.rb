class Inventory < ApplicationRecord
	# has_many :inventory_requestrak
	belongs_to :employee
  has_one :category
	validates :item_name, presence: true

    def categories
        categories = category
        {
            id: categories&.id,
            category_id: categories&.category_id,
            category_name: categories&.category_name,
            category_barcode: categories&.category_barcode
        }
    end

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

	def self.filter(keyword)
		if keyword.present?
			where(
        "CAST(inventories.id AS TEXT) LIKE :search OR
        category LIKE :search
       ",
        search: "%#{keyword}%")
		else
		end
	end
end
