class ExpenseItem < ApplicationRecord
	belongs_to :expense
	has_many :expense_tag_items, dependent: :destroy

	# return [1,2,3...] #id
	def tags
	  ExpenseTagItem.where(expense_item_id: self.id).collect(&:expense_tag_id)
	end

	# values = [1,2,3...] #id
	def tags=(values)
		self.expense_tag_items.destroy_all
	  values.each do |value|
			self.expense_tag_items << ExpenseTagItem.new(
				expense_item: self,
				expense_tag: ExpenseTag.where(id: value[1][:id]).first
			)
		end
	end

	def as_json(options={})
		{
			amount: self.amount,
			cost: self.cost,
			detail: self.detail,
			expense_id: self.expense_id,
			id: self.id,
			tags: ExpenseTag.where(id: self.tags)
		}
	end
end
