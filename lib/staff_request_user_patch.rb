require_dependency 'user'

module StaffRequestPlugin
  module UserPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        has_many :staff_requests, :foreign_key => :author_id, :dependent => :destroy
#        has_one :staff_request_manager, :dependent => :destroy
#        has_many :staff_request_approvers, :through => :staff_request_manager, :dependent => :destroy
#        has_many :approvers, :through => :staff_request_approvers, :foreign_key => :approver_id, :class_name => "User"

#        scope :not_staff_request_managers, lambda {
#          { :conditions => ["#{User.table_name}.id NOT IN (SELECT #{StaffRequestManager.table_name}.user_id FROM #{StaffRequestManager.table_name})"] }
#        }

#        scope :staff_request_managers, lambda {
#          { :conditions => ["#{User.table_name}.id IN (SELECT #{StaffRequestManager.table_name}.user_id FROM #{StaffRequestManager.table_name})"] }
#        }

#        scope :not_approvers, lambda { |manager|
#          {
#            :conditions => ["#{User.table_name}.id NOT IN (:manager_ids)", {:manager_ids => manager.approvers.map(&:id) + [manager.user_id]}]
#          }
#        }
      end
    end

    module ClassMethods

    end

    module InstanceMethods
      def staff_request_manager?
#        self.staff_request_manager.present?
        begin
          principal = Principal.find(Setting[:plugin_redmine_staff_request][:principal_id])
          if principal.is_a?(Group)
            principal.users.include?(self)
          elsif principal.is_a?(User)
            principal == self
          end
        rescue
          nil
        end
      end
    end
  end
end
