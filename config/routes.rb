ActionController::Routing::Routes.draw do |map|
  map.resources :apps, :customers, :deployments, :destinations, :hosts, :instances, :requirements, :services
  map.resources :requirements, :only => [ :create, :destroy ]
  map.resources :edges, :collection => { :link => :post }

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.root :controller => 'hosts', :action => 'index'
end
