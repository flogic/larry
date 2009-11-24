require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AppsController, 'routing' do
  it_should_behave_like 'a RESTful controller with routes'
  
  it "should build params :customer_id => '1', :controller => 'apps', :action => 'new' from GET /customers/1/apps/new" do
    params_from(:get, '/customers/1/apps/new').should == { :controller => 'apps', :action => 'new', :customer_id => '1' }
  end

  it "should map :controller => 'apps', :action => 'new', :customer_id => '1' to /customers/1/apps/new" do
    route_for(:controller => 'apps', :action => 'new', :customer_id => '1').should == "/customers/1/apps/new"
  end  
  
  it "should build params :customer_id => '1', :controller => 'apps', :action => 'create' from POST /customers/1/apps" do
    params_from(:post, '/customers/1/apps').should == { :controller => 'apps', :action => 'create', :customer_id => '1' }
  end

  it "should map :controller => 'apps', :action => 'create', :customer_id => '1' to /customers/1/apps" do
    route_for(:controller => 'apps', :action => 'create', :customer_id => '1').should == { :path => "/customers/1/apps", :method => 'post' }
  end  
end
