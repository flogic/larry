require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe InstancesController, 'routing' do
  it_should_behave_like 'a RESTful controller with routes'
  
  it "should build params :app_id => '1', :controller => 'instances', :action => 'new' from GET /apps/1/instances/new" do
    params_from(:get, '/apps/1/instances/new').should == { :controller => 'instances', :action => 'new', :app_id => '1' }
  end

  it "should map :controller => 'instances', :action => 'new', :app_id => '1' to /apps/1/instances/new" do
    route_for(:controller => 'instances', :action => 'new', :app_id => '1').should == "/apps/1/instances/new"
  end  
  
  it "should build params :app_id => '1', :controller => 'instances', :action => 'create' from POST /apps/1/instances" do
    params_from(:post, '/apps/1/instances').should == { :controller => 'instances', :action => 'create', :app_id => '1' }
  end

  it "should map :controller => 'instances', :action => 'create', :app_id => '1' to /apps/1/instances" do
    route_for(:controller => 'instances', :action => 'create', :app_id => '1').should == { :path => "/apps/1/instances", :method => 'post' }
  end
  
  it "should build params :id => '1', :controller => 'instances', :action => 'new_deployment' from GET /instances/1/new_deployment" do
    params_from(:get, '/instances/1/new_deployment').should == { :controller => 'instances', :action => 'new_deployment', :id => '1' }
  end

  it "should map :controller => 'instances', :action => 'new_deployment', :id => '1' to /instances/1/new_deployment" do
    route_for(:controller => 'instances', :action => 'new_deployment', :id => '1').should == "/instances/1/new_deployment"
  end  

  it "should build params :controller => 'instances', :action => 'deploy' from POST /instances/1/deploy" do
    params_from(:post, '/instances/1/deploy').should == { :controller => 'instances', :action => 'deploy', :id => '1' }
  end

  it "should map :controller => 'instances', :action => 'deploy', :id => '1' to /instances/1/deploy" do
    route_for(:controller => 'instances', :action => 'deploy', :id => '1').should == { :path => "/instances/1/deploy", :method => 'post' }
  end
end
