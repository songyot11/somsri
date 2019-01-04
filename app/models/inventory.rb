class Inventory < ApplicationRecord
	# has_many :inventory_requestrak
	belongs_to :employee
    has_one :category
    belongs_to :supplier
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
        lower(item_name) LIKE :search OR
        lower(serial_number) LIKE :search OR
        lower(model) LIKE :search OR
        to_char(inventories.date_purchase::date, 'dd/mm/yyyy') LIKE :search OR
        lower(employees.first_name) LIKE :search OR 
        lower(employees.last_name) LIKE :search OR
        employees.first_name_thai LIKE :search OR
        employees.last_name_thai LIKE :search
       ",
        search: "%#{keyword.downcase}%")
    else 
			self.all
		end
	end
end
