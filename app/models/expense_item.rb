class ExpenseItem < ApplicationRecord
	belongs_to :expense
	has_many :expense_tag_items, dependent: :destroy

	# return [{ text: "tag_name" },...]
	def tags
	  expense_tag_items.collect do |eti|
			{ text: eti.expense_tag.name } if eti.expense_tag
		end
	end

	# values = [{ text: "tag_name" },...]
	def tags=(values)
		self.expense_tag_items = []
	  values.each do |value|
			self.expense_tag_items << ExpenseTagItem.new(
				expense_item: self,
				expense_tag: ExpenseTag.where(name: value[1]["text"]).first_or_initialize
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
			tags: self.tags
		}
	end
end
