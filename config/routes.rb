ActionController::Routing::Routes.draw do |map|
  map.resources :apps, :customers, :deployments, :destinations, :hosts, :instances, :services

  map.resources :edges,        :only => [ :create, :destroy ]
  map.resources :requirements, :only => [ :create, :destroy ]

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.root :controller => 'hosts', :action => 'index'
end
