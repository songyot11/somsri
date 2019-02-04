class Taxrate < ApplicationRecord
  after_save :clear_cache
  def clear_cache
    Rails.cache.delete(:taxrate_all)
  end

  def self.all_cached
    return Rails.cache.fetch(:taxrate_all) do
      Taxrate.all.to_a
    end
  end
end
