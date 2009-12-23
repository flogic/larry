require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe RequirementsController, 'routing' do
  it "should map :controller => 'user_sessions', :action => 'compute_time_zone_offset' to /user_sessions/compute_time_zone_offset" do
    route_for(:controller => 'user_sessions', :action => 'compute_time_zone_offset').should == { :path => '/user_sessions/compute_time_zone_offset', :method => 'post' }
  end

  it "should build params :controller => 'user_sessions', :action => 'compute_time_zone_offset' from GET /user_sessions/compute_time_zone_offset" do
    params_from(:get, '/user_sessions/compute_time_zone_offset').should == { :controller => 'user_sessions', :action => 'compute_time_zone_offset' }
  end
end
