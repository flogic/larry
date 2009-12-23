require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserSessionsController, 'when integrating' do
  integrate_views

  describe 'compute_time_zone_offset' do
    before :each do
      @offset_minutes = 0
    end
    
    def do_request
      get :compute_time_zone_offset, :offset_minutes => @offset_minutes
    end
    
    it 'should set the time zone to the rails time zone object when the time zone is known' do
      @offset_minutes = -360
      do_request
      assigns[:time_zone].name.should == 'Central America'
    end
    
    it 'should set the session time zone name correctly when the time zone is known' do
      @offset_minutes = -360
      do_request
      session[:time_zone_name].should == 'Central America'
    end

    it 'should set the time zone to the rails UTC time zone object when the time zone is unknown' do
      @offset_minutes = -3245
      do_request
      assigns[:time_zone].name.should == 'UTC'
    end
    
    it 'should set the session time zone name to UTC when the time zone is unknown' do
      @offset_minutes = -3245
      do_request
      session[:time_zone_name].should == 'UTC'
    end

    it 'should be successful' do
      do_request
      response.should be_success
    end
    
    it 'should not use a layout' do
      do_request
      response.layout.should be_nil
    end
    
    it 'should render a success message' do
      do_request
      response.body.should == 'success'
    end
  end

  class UserSessionsController
    def test_configuring_time_zone
      render :text => ''
    end
  end

  describe 'configuring user time zone' do
    def do_request
      get :test_configuring_time_zone
    end
    
    it 'should set the time zone attribute if there is a session time zone name' do
      session[:time_zone_name] = 'Central America'
      do_request
      assigns[:time_zone].name.should == 'Central America'
    end
    
    it 'should not set the time zone attribute if there is no session time zone name' do
      do_request
      assigns[:time_zone].should be_nil
    end
    
    it 'should set the rails time zone based on session time zone if set' do
      session[:time_zone_name] = 'Central America'
      do_request
      Time.zone.name.should == 'Central America'
    end
    
    it 'should not set the rails time zone based on session time zone if not set' do
      lambda { do_request }.should_not change(Time, :zone)
    end
  end
end