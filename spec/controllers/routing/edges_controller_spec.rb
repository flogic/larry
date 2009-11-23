require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe EdgesController, 'routing' do
  it "should map :controller => 'edges', :action => 'create' to /edges" do
    route_for(:controller => 'edges', :action => 'create').should == { :path => '/edges', :method => 'post' }
  end

  it "should map :controller => 'edges', :action => 'destroy', :id => '1' to /edges/1" do
    route_for(:controller => 'edges', :action => 'destroy', :id => '1').should == { :path => "/edges/1", :method => 'delete' }
  end

  it "should build params :controller => 'edges', :action => 'create' from POST /edges" do
    params_from(:post, '/edges').should == { :controller => 'edges', :action => 'create' }
  end

  it "should build params :controller => 'edges', :action => 'destroy', :id => '1' from DELETE /edges/1" do
    params_from(:delete, '/edges/1').should == { :controller => 'edges', :action => 'destroy', :id => '1' }
  end
end
