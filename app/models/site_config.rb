class SiteConfig < ApplicationRecord
  before_create :can_only_has_one
  after_save :clear_config_cache

  def destroy
  end

  def self.get_cache
    return Rails.cache.fetch(:site_config) do
      site_config = SiteConfig.first
      site_config = SiteConfig.create if !site_config
      site_config
    end
  end

  private
  def can_only_has_one
    raise "Error: Config can only has one." if SiteConfig.count > 0
  end

  def clear_config_cache
    Rails.cache.delete(:site_config)
  end
end
