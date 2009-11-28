require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe DeploymentsController, 'routing' do
  it_should_behave_like 'a RESTful controller with routes'
  
  it "should build params :instance_id => '1', :controller => 'deployments', :action => 'new' from GET /instances/1/deployments/new" do
    params_from(:get, '/instances/1/deployments/new').should == { :controller => 'deployments', :action => 'new', :instance_id => '1' }
  end

  it "should map :controller => 'deployments', :action => 'new', :instance_id => '1' to /instances/1/deployments/new" do
    route_for(:controller => 'deployments', :action => 'new', :instance_id => '1').should == "/instances/1/deployments/new"
  end  
  
  it "should build params :instance_id => '1', :controller => 'deployments', :action => 'create' from POST /instances/1/deployments" do
    params_from(:post, '/instances/1/deployments').should == { :controller => 'deployments', :action => 'create', :instance_id => '1' }
  end

  it "should map :controller => 'deployments', :action => 'create', :instance_id => '1' to /instances/1/deployments" do
    route_for(:controller => 'deployments', :action => 'create', :instance_id => '1').should == { :path => "/instances/1/deployments", :method => 'post' }
  end  
end
