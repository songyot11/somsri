class ChangeDatePurchaseAndDateAddToDate < ActiveRecord::Migration[5.0]
  def up
  	change_column :inventories, :date_purchase, "timestamp USING date_purchase::timestamp without time zone"
  	change_column :inventories, :date_add, "timestamp USING date_add::timestamp without time zone"
  	change_column :inventories, :end_warranty, "timestamp USING end_warranty::timestamp without time zone"
  	change_column :inventory_requests, :request_date, "timestamp USING request_date::timestamp without time zone"
  	change_column :manage_inventory_requests, :date_purchase, "timestamp USING date_purchase::timestamp without time zone"
  	change_column :manage_inventory_requests, :date_send, "timestamp USING date_send::timestamp without time zone"
  	change_column :manage_inventory_requests, :get_date, "timestamp USING get_date::timestamp without time zone"
  	change_column :manage_inventory_requests, :end_warranty, "timestamp USING end_warranty::timestamp without time zone"
  end

  def down
  	change_column :inventories ,:date_purchase, :string
  	change_column :inventories ,:date_add, :string
  	change_column :inventories ,:end_warranty, :string
  	change_column :inventory_requests, :request_date, :string
  	change_column :manage_inventory_requests, :date_purchase, :string
  	change_column :manage_inventory_requests, :date_send, :string
  	change_column :manage_inventory_requests, :get_date, :string
  	change_column :manage_inventory_requests, :end_warranty, :string
  end
end
