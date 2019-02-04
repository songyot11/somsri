class AddWebCmsToSiteConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :web_cms, :boolean, default: false
  end
end
