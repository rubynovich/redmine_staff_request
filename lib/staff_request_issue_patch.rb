require_dependency 'issue'
require_dependency 'issue_status'

module StaffRequestPlugin
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        has_one :staff_request
#        , :dependent => :destroy
      end

    end

    module ClassMethods

    end

    module InstanceMethods

    end
  end
end
