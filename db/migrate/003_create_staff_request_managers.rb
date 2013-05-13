class CreateStaffRequestManagers < ActiveRecord::Migration
  def change
    create_table :staff_request_managers do |t|
      t.integer :user_id
      t.datetime :created_on
    end
  end
end
