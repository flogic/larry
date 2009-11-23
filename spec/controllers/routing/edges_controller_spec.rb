require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe EdgesController, 'routing' do
  it_should_behave_like 'a RESTful controller with routes'
  
  it "should map :source_id => '1', :target_id => '2', :controller => 'edges', :action => 'link' to /edges/link" do
    route_for(:action => 'link', :controller => 'edges').should == { :path => '/edges/link', :method => :post }
  end
  
  it "should build :controller => :edges, :action => 'link' from POST /edges/link" do
    params_from(:post, '/edges/link').should == { :controller => 'edges', :action => 'link' }
  end
end
