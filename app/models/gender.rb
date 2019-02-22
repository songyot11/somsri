class Gender < ApplicationRecord
  after_save :clear_cache
  def clear_cache
    Rails.cache.delete(:gender_male)
    Rails.cache.delete(:gender_female)
    Rails.cache.delete(:gender_all)
    Gender.all.each do |gender|
      Rails.cache.delete("gender_find_by_id_#{gender.id}".to_sym)
    end
  end

  def self.find_by_id_cached(id)
    return Rails.cache.fetch("gender_find_by_id_#{id}".to_sym) do
      Gender.where(id: id).first
    end
  end

  def self.male
    return Rails.cache.fetch(:gender_male) do
      Gender.find_by_name("Male")
    end
  end

  def self.female
    return Rails.cache.fetch(:gender_female) do
      Gender.find_by_name("Female")
    end
  end

  def self.all_cached
    return Rails.cache.fetch(:gender_all) do
      Gender.all.to_a
    end
  end

  def translated_gender
    I18n.t(self[:name])
  end  
end
