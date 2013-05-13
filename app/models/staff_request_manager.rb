class StaffRequestManager < ActiveRecord::Base
  unloadable

  belongs_to :user
  has_many :staff_request_approvers, :foreign_key => :manager_id, :dependent => :destroy
  has_many :approvers, :through => :staff_request_approvers

  validates_presence_of :user_id
  validates_uniqueness_of :user_id
end
