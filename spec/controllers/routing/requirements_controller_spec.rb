require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe RequirementsController, 'routing' do
  it "should map :controller => 'requirements', :action => 'create' to /requirements" do
    route_for(:controller => 'requirements', :action => 'create').should == { :path => '/requirements', :method => 'post' }
  end

  it "should map :controller => 'requirements', :action => 'destroy', :id => '1' to /requirements/1" do
    route_for(:controller => 'requirements', :action => 'destroy', :id => '1').should == { :path => "/requirements/1", :method => 'delete' }
  end
  
  it "should build params :controller => 'requirements', :action => 'create' from POST /requirements" do
    params_from(:post, '/requirements').should == { :controller => 'requirements', :action => 'create' }
  end

  it "should build params :controller => 'requirements', :action => 'destroy', :id => '1' from DELETE /requirements/1" do
    params_from(:delete, '/requirements/1').should == { :controller => 'requirements', :action => 'destroy', :id => '1' }
  end
end
