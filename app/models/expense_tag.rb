class ExpenseTag < ApplicationRecord
	has_many :expense_tag_items, dependent: :destroy

	def self.search(keyword)
    if keyword.present?
      where("name ILIKE ? ", "%#{keyword}%")
    else
      all
    end
  end

	def related_tag_ids
		tag_tree = SiteConfig.get_cache.expense_tag_tree_hash
		ids = []
		lv = tag_tree.find{|tt| tt[:id] == self.id }[:lv]
		lv_count = lv
		tag_tree.reverse_each do |tt|
			if ((lv_count == lv) && (tt[:id] == self.id))
				ids << tt[:id]
				lv_count += 1
			elsif ((lv_count > lv) && (lv_count == tt[:lv]))
				ids << tt[:id]
				lv_count += 1
			end
		end
		return ids
	end

	def is_left
		tag_tree = SiteConfig.get_cache.expense_tag_tree_hash
		lv = 0
		tag_tree.each do |tt|
			lv = tt[:lv] if lv == 0 && tt[:id] == self.id
			return false if lv > 0 && lv > tt[:lv]
		end
		return true
	end

	def level
		tag_tree = SiteConfig.get_cache.expense_tag_tree_hash
		return tag_tree.find{|tt| tt[:id] == self.id }[:lv]
	end

	def as_json(options={})
    {
			name: self.name,
			ids: self.related_tag_ids,
			id: self.id,
			is_left: self.is_left,
			lv: self.level,
			description: self.description
		}
  end
end
