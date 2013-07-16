# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  resources :staff_requests do 
    collection do
      get :autocomplete_for_name
      get :autocomplete_for_department_name
      get :autocomplete_for_boss_name
    end
  end
#  resources :staff_request_managers do
#    collection do
#      get :autocomplete_for_manager
#    end
#    member do
#      get :autocomplete_for_approver
#    end
#  end
end
