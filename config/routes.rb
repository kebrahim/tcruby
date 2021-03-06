Tcruby::Application.routes.draw do
  # password reset
  get "/password_resets/new" => "password_resets#new", :as => "new_password_reset"
  post "/password_resets" => "password_resets#create"
  get "/password_resets/:id/edit" => "password_resets#edit", :as => "edit_password_reset"
  put "/password_resets/:id" => "password_resets#update"

  # picks
  get "picks" => "picks#index"
  get "picks/week/:number" => "picks#picks_week"
  get "ajax/picks/week/:number" => "picks#ajax_picks_week"
  post "picks/week/:number" => "picks#update_picks"

  # weeks
  get "weeks" => "weeks#index"
  post "weeks" => "weeks#update"

  # stats
  get "scoreboard" => "stats#scoreboard"
  get "scoreboard/week/:number" => "stats#scoreboard_week"
  get "ajax/scoreboard/week/:number" => "stats#ajax_scoreboard_week"
  get "scores" => "stats#scores"
  get "scores/week/:number" => "stats#scores_week"
  get "ajax/scores/week/:number" => "stats#ajax_scores_week"
  post "scores/week/:number" => "stats#update_scores"

  # chefs
  get "chefs" => "chefs#index"
  get "chefs/:id" => "chefs#show"
  get "ajax/chefs/:id" => "chefs#ajax_chef"

  # sessions
  resources :sessions
  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  root :to => "sessions#new"

  # users
  resources :users
  get "dashboard" => "users#dashboard"
  get "profile" => "users#profile"
  get "teams" => "users#teams"
  get "teams/:user_id" => "users#team"
  get "ajax/teams/:user_id" => "users#ajax_team"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
