ActionController::Routing::Routes.draw do |map|
  map.resources :deployments, :destinations, :hosts, :services

  map.connect '/hosts/configuration/*name', :controller => 'hosts', :action => 'configuration'

  map.resources :customers,    :has_many => :apps
  map.resources :apps,         :has_many => :instances
  map.resources :instances,    :member => { :new_deployment => :get, :deploy => :post }, :has_many => :deployments
  map.resources :edges,        :only => [ :create, :destroy ]
  map.resources :requirements, :only => [ :create, :destroy ]

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  map.root :controller => 'hosts', :action => 'index'
end
