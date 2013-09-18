class AddBossIdToStaffRequests < ActiveRecord::Migration
  def change
    add_column :staff_requests, :boss_id, :integer
    add_index :staff_requests, :boss_id
  end
end
