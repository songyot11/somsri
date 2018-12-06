class Inventory < ApplicationRecord
	has_many :inventoy_requests
	validates :item_name, presence: true	
end
