Redmine::Plugin.register :redmine_staff_request do
  name 'Staff Request'
  author 'Roman Shipiev'
  description 'Staff request for Redmine'
  version '0.0.1'
  url 'https://bitbucket.org/rubynovich/redmine_staff_request'
  author_url 'http://roman.shipev.me'

  settings :default => {
                       :duration => 7
                     },
         :partial => 'staff_requests/settings'


  Redmine::MenuManager.map :top_menu do |menu| 

    unless menu.exists?(:workflow)
      menu.push(:workflow, "#", 
                { :after => :internal_intercourse,
                  :parent => :top_menu, 
                  :caption => :label_workflow_menu
                })
    end

    menu.push(:staff_requests, 
              {:controller => :staff_requests, :action => :index},
              { :parent => :workflow,
                :caption => :label_staff_request_plural,
                :if => Proc.new{User.current.staff_request_manager?}
              })

  end

end

Rails.configuration.to_prepare do
  [:issue, :user].each do |cl|
    require "staff_request_#{cl}_patch"
  end

  require_dependency 'staff_request'
  require 'time_period_scope'

  [
   [Issue, StaffRequestPlugin::IssuePatch],
   [User, StaffRequestPlugin::UserPatch],
   [StaffRequest, TimePeriodScope]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
