class ExpenseTag < ApplicationRecord
	has_many :expense_tag_items

	def self.search(keyword)
    if keyword.present?
      where("name ILIKE ? ", "%#{keyword}%")
    else
      all
    end
  end

	def as_json(options={})
    if options[:autocomplete]
      return self.name
    else
      super()
    end
  end
end
