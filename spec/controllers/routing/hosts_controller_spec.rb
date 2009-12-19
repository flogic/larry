require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe HostsController, 'routing' do
  it_should_behave_like 'a RESTful controller with routes'
  
  it "should map the application root to the hosts index" do
    params_from(:get, "/").should == {:controller => "hosts", :action => "index"}
  end
  
  it "should build params :name => 'foohost', :format => 'pp', :controller => 'hosts', :action => 'configuration' from GET /hosts/configuration/foohost.pp" do
    params_from(:get, '/hosts/configuration/foohost.pp').should == { :controller => 'hosts', :action => 'configuration', :name => 'foohost', :format => 'pp' }
  end

  it "should map :controller => 'hosts', :action => 'configuration', :name => 'foohost' to /hosts/configuration/foohost" do
    route_for(:controller => 'hosts', :action => 'configuration', :name => 'foohost').should == "/hosts/configuration/foohost"
  end  
end
