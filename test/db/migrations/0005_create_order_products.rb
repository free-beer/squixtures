Sequel.migration do
	up do
		create_table(:order_products) do
			primary_key :id
			foreign_key :order_id, :orders
			foreign_key :product_id, :products
			Integer :quantity, :null => false
			Time :created, :null => false
			Time :updated, :null => true
		end
	end

	down do
		drop_table(:order_products)
	end
end