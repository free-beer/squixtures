Sequel.migration do
	up do
		create_table(:products) do
			primary_key :id
			foreign_key :category_id, :categories
			String :name, :size => 200
			Float :cost, :null => false, :precision => 6, :scale => 2
			Time :created, :null => false
			Time :updated, :null => true
		end
	end

	down do
		drop_table(:products)
	end
end