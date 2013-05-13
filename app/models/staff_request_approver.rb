class StaffRequestApprover < ActiveRecord::Base
  unloadable

  belongs_to :approver, :foreign_key => :approver_id, :class_name => "User"
  belongs_to :manager,  :foreign_key => :manager_id,  :class_name => "StaffRequestManager"

  validates_presence_of :manager_id, :approver_id
  validates_uniqueness_of :approver_id, :scope => :manager_id
end
