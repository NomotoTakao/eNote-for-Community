ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'm_users', :action => 'create'
  map.signup '/signup', :controller => 'm_users', :action => 'new'
  map.resources :m_users

  map.resource :session

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.

  map.namespace :schedule do |m|
    m.resources :reserve, :collection => {:month => :get, :index_month => :get, :week => :get,
    :index_week => :get, :day => :get, :index_day => :get, :list => :get, :index_list => :get,
    :spare_time_other_member => :get, :spare_time_facility => :get, :other_member_list => :get,
    :undecided_member => :get, :facility_list => :get, :secretary_print => :get}
  end


  map.namespace :facility do |m|
    m.resources :reserve, :collection => {:month => :get, :index_month => :get, :week => :get,
    :index_week => :get, :day => :get, :index_day => :get, :list => :get, :index_list => :get}
  end



  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.connect '', :controller => 'home/mypage', :action => 'index'
#  map.connect '', :controller => 'sample', :action => 'bbs_entry'

end
