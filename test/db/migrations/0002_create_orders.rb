Sequel.migration do
	up do
		create_table(:orders) do
			primary_key :id
			foreign_key :user_id, :users
			Integer :status, :null => false
			Time :created, :null => false
			Time :updated, :null => true
		end
	end

	down do
		drop_table(:orders)
	end
end