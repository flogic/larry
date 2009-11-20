require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe HostsController, 'routing' do
  it_should_behave_like 'a RESTful controller with routes'
  
  it "should map the application root to the hosts index" do
    params_from(:get, "/").should == {:controller => "hosts", :action => "index"}
  end
end
