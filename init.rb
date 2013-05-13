Redmine::Plugin.register :redmine_staff_request do
  name 'Redmine Staff Request plugin'
  author 'Roman Shipiev'
  description 'Staff request for Redmine'
  version '0.0.1'
  url 'https://github.com/rubynovich/redmine_staff_request'
  author_url 'http://roman.shipev.me'

  settings :default => {
                       :project_id => Project.active.last.try(:id),
                       :tracker_id => Project.active.last.trackers.first.try(:id),
                       :duration => 7
                     },
         :partial => 'settings/settings'
end

Rails.configuration.to_prepare do
  [:issue].each do |cl|
    require "staff_request_#{cl}_patch"
  end

  [
    [Issue, StaffRequestPlugin::IssuePatch]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
