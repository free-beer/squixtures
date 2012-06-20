Sequel.migration do
	up do
		create_table(:categories) do
			primary_key :id
			String :name, :limit => 100, :null => false
			Time :created, :null => false
			Time :updated, :null => true
		end
	end

	down do
		drop_table(:categories)
	end
end