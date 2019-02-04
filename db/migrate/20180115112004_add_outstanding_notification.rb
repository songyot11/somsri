class AddOutstandingNotification < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :outstanding_notification, :boolean, default: false
  end
end
