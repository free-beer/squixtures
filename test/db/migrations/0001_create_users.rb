Sequel.migration do
	up do
		create_table(:users) do
			primary_key :id
			String :email, :null => false, :size => 255, :unique => true
			String :passwd, :null => false, :size => 100
			Integer :status, :null => false
			Time :created, :null => false
			Time :updated, :null => true
		end
	end

	down do
		drop_table(:users)
	end
end