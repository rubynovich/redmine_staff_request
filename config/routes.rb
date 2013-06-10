# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  resources :staff_requests
#  resources :staff_request_managers do
#    collection do
#      get :autocomplete_for_manager
#    end
#    member do
#      get :autocomplete_for_approver
#    end
#  end
end
