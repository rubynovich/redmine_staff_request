class CreateStaffRequestApprovers < ActiveRecord::Migration
  def change
    create_table :staff_request_approvers do |t|
      t.integer :manager_id
      t.integer :approver_id
      t.datetime :created_on
    end
  end
end
