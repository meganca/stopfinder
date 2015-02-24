StopfinderDev::Application.routes.draw do
 # devise_for :users

  root :to => 'about#main'
  
  resources :busstops
  resources :closures
  resources :contact_forms
  resources :sresponses
  #resources :authorizations
  
  get '/update/:id' => 'busstops#update', :as => :submitinfo
  get '/edit/:id' => 'busstops#edit', :as => :duplicateentry
  get '/add/:id' => 'busstops#addnew'
  get '/closed/:id' => 'closures#report'
  get '/profile' => 'reputation#profile', :as => :userprofile
  get '/user/:id' => 'reputation#publicprofile'
  get '/topcontributors' => 'reputation#top'
  get '/badges' => 'reputation#badges'
  get '/confirm' => 'reputation#confirmdelete'
  get '/delete' => 'reputation#delete', :as => :deleteaccount
  get '/about/faq' => 'about#faq'
  get '/find' => 'about#find'
  get '/usernotfound' => 'reputation#usernotfound', :as => :missinguser
  get '/survey/' => 'sresponses#surveyform', :as => :takesurvey
  match 'about/entry/:id' => 'about#entry', :as => :dataentry
  match 'about/survey/submitted'  => 'about#survey', :as => :surveyresponse
  match 'about/contact/:id' => 'about#contact', :as => :emailentry
  match 'about/deleted' => 'about#deleted', :as => :accountdeleted
  match '/testing' => 'about#testing'
  match '/busstops/:id' => 'busstops#show', :as => :dataview
  
  # Routing for info/tutorials
  get '/about/fields' => 'about#data'
  get '/about/missing' => 'about#missing'
  
  # Routing for login
  get   '/login', :to => 'sessions#new', :as => :login
  get   '/logout', :to => 'sessions#destroy', :as => :logout
  #get	'/manage/account', :to => 'sessions#edit', as => :manage
  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/auth/failure', :to => 'sessions#failure'

  #Routing for reputation/profile
  post '/profile' => 'reputation#create'
  post 'about/main' => 'about#create'
  
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
