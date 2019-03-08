class SiteConfig < ApplicationRecord
  include ActiveModel::Dirty
  before_create :can_only_has_one
  after_save :clear_config_cache, :regenerate_tax

  def regenerate_tax
    if self.tax_changed?
      Payroll.where(closed: [nil, false]).each do |payroll|
        payroll.generate_tax!
      end
    end
  end

  def destroy
  end

  def self.get_cache
    return Rails.cache.fetch(:site_config) do
      site_config = SiteConfig.first
      site_config.update(default_locale: 'th') if site_config&.default_locale&.blank?
      site_config = SiteConfig.create(default_locale: 'th') if site_config.reload.blank?
      site_config
    end
  end

  def expense_tag_tree_hash
    if self.expense_tag_tree.present?
      return JSON.parse(self.expense_tag_tree).collect { |ett| ett.deep_symbolize_keys }
    else
      return []
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
