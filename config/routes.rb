ActionController::Routing::Routes.draw do |map|
  map.resources :apps, :deployments, :destinations, :hosts, :instances, :services

  map.resources :customers,    :has_many => :apps
  map.resources :edges,        :only => [ :create, :destroy ]
  map.resources :requirements, :only => [ :create, :destroy ]

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.root :controller => 'hosts', :action => 'index'
end
