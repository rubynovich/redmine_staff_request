require_dependency 'user'

module StaffRequestPlugin
  module UserPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        has_many :staff_requests
      end
    end

    module ClassMethods

    end

    module InstanceMethods

    end
  end
end
