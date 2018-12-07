class Inventory < ApplicationRecord
	has_many :inventory_request
	validates :item_name, presence: true	
end
