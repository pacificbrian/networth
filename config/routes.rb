ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tax', 'taxes'
end

NwGit::Application.routes.draw do
  #devise_for :users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  resources :accounts do
    resources :cash_flows
    resources :r_cash_flows
    resources :split_cash_flows
    resources :trades
    resources :trade_types
    resources :gains 
    resources :securities 
    resources :charts 
    resources :balances 
    resources :payees  do
      resources :tax_items
    end
    resources :import 
    resources :tax_items
    resources :user_categories
    resources :categories
    get 'refresh', :on => :collection
    get 'watchlist', :on => :collection
  end
  resources :import
  resources :user_categories
  resources :categories
  resources :payees do
    resources :tax_items
  end
  resources :cash_flows
  resources :r_cash_flows do
    get 'apply', :on => :member
  end
  resources :split_cash_flows
  resources :securities do
    resources :trades
    resources :trade_types
    resources :security_alerts
    resources :charts 
    get 'all', :on => :collection
  end
  resources :security_alerts
  resources :portfolios
  resources :charts
  resources :companies do
    resources :charts
    resources :quotes
  end
  resources :quotes
  resources :quote_settings
  resources :taxes
  resources :tax_users
  resources :tax_items
  resources :tax_types
  resources :tax_categories
  resources :tax_years
  resources :years do
    resources :import
    resources :taxes
    resources :tax_users
    resources :tax_items
    resources :tax_types
    resources :trades
    resources :trade_types
    resources :gains 
    resources :payees do
      resources :tax_items
    end
    resources :accounts do
      resources :balances 
      resources :import
      resources :charts
      resources :user_categories
      resources :categories
      resources :payees do
        resources :tax_items
      end
      resources :taxes
      resources :tax_items
      resources :trades
      resources :trade_types
      resources :gains 
    end
  end
  resources :sessions
  resources :session, :controller => 'sessions'
  resources :users do
    get 'dashboard', :on => :member
    get 'refresh', :on => :member
  end

  match "login" => "session#new"
  match "logout" => "session#destroy"
  match "home" => "users#dashboard"
  match "register" => "users#new"
  match "signup" => "users#new"
  match "activate/:activation_code" => "users#activate"

  # Activation:
  # activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  # add to config/environment.rb
  # config.active_record.observers = :user_observer

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
  root :to => 'accounts#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
