Redmine::Plugin.register :redmine_staff_request do
  name 'Staff Request'
  author 'Roman Shipiev'
  description 'Staff request for Redmine'
  version '0.0.1'
  url 'https://bitbucket.org/rubynovich/redmine_staff_request'
  author_url 'http://roman.shipev.me'

  settings :default => {
                       :project_id => Project.active.last.try(:id),
                       :tracker_id => Project.active.last.trackers.first.try(:id),
                       :principal_id => nil,
                       :duration => 7
                     },
         :partial => 'settings/settings'

  menu :top_menu, :staff_requests, {:controller => :staff_requests, :action => :index}, :caption => :label_staff_request_plural, :if => Proc.new{User.current.staff_request_manager?}

#  menu :admin_menu, :staff_request_managers,
#    {:controller => :staff_request_managers, :action => :index}, :caption => :label_staff_request_manager_plural, :html => {:class => :users}
end

Rails.configuration.to_prepare do
  [:issue, :user].each do |cl|
    require "staff_request_#{cl}_patch"
  end

  [
    [Issue, StaffRequestPlugin::IssuePatch],
    [User, StaffRequestPlugin::UserPatch]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
