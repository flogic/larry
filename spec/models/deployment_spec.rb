require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Deployment do
  describe 'attributes' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'should have a deployable id' do
      @deployment.should respond_to(:deployable_id)
    end
    
    it 'should allow setting and retrieving the deployable id' do
      @deployment.deployable_id = 1
      @deployment.deployable_id.should == 1
    end
    
    it 'should have a reason' do
      @deployment.should respond_to(:reason)
    end
    
    it 'should allow setting and retrieving the reason' do
      @deployment.reason = 'initial deployment'
      @deployment.reason.should == 'initial deployment'
    end
    
    it 'should have a start time' do
      @deployment.should respond_to(:start_time)
    end
    
    it 'should allow setting and retrieving the start time' do
      @deployment.start_time = time = Time.now
      @deployment.start_time.should == time
    end
    
    it 'should have an end time' do
      @deployment.should respond_to(:end_time)
    end
    
    it 'should allow setting and retrieving the end time' do
      @deployment.end_time = time = 1.day.from_now
      @deployment.end_time.should == time
    end
  end
  
  describe 'validations' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'should not be valid without a deployable' do
      @deployment.deployable = nil
      @deployment.valid?
      @deployment.errors.should be_invalid(:deployable)
    end

    it 'should be valid with a deployable' do
      @deployment.deployable = Deployable.generate!
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:deployable)
    end
    
    it 'should not be valid without a reason' do
      @deployment.reason = nil
      @deployment.valid?
      @deployment.errors.should be_invalid(:reason)
    end

    it 'should not be valid without a non-blank reason' do
      @deployment.reason = ''
      @deployment.valid?
      @deployment.errors.should be_invalid(:reason)
    end
    
    it 'should be valid with a reason' do
      @deployment.reason = 'test deployment'
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:reason)
    end
    
    it 'should not allow start time to be nil' do
      @deployment.start_time = nil
      @deployment.valid?
      @deployment.errors.should be_invalid(:start_time)
    end
    
    it 'should not allow start time to be in the past' do
      @deployment.start_time = 2.minutes.ago
      @deployment.valid?
      @deployment.errors.should be_invalid(:start_time)
    end
    
    it 'should not allow end time to be in the past' do
      @deployment.end_time = 2.minutes.ago
      @deployment.valid?
      @deployment.errors.should be_invalid(:end_time)      
    end
    
    it 'should not allow end time to be before start time' do
      @deployment.end_time = 10.minutes.from_now
      @deployment.start_time = 15.minutes.from_now
      @deployment.valid?
      @deployment.errors.should be_invalid(:end_time)            
    end
    
    it 'should be valid with a start time in the future' do
      @deployment.start_time = 5.minutes.from_now
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:start_time)            
    end
  
    it 'should be valid with a nil end time' do
      @deployment.end_time = nil
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:end_time)            
    end
    
    it 'should be valid with an end time in the future and later than the start time' do
      @deployment.start_time = 10.minutes.from_now
      @deployment.end_time = nil
      @deployment.valid?
      @deployment.errors.should_not be_invalid(:end_time)
    end
  end
  
  describe 'relationships' do
    before :each do
      @deployment = Deployment.new
    end
    
    it 'should have deployed services' do
      @deployment.should respond_to(:deployed_services)
    end
    
    it 'should allow setting and retrieving deployed services' do
      @deployment.deployed_services << deployed_services = Array.new(2) { DeployedService.generate! }
      @deployment.deployed_services.sort_by(&:id).should == deployed_services.sort_by(&:id)
    end
    
    it 'should belong to a deployable' do
      @deployment.should respond_to(:deployable)      
    end
    
    it 'should allow assigning the deployable' do
      @deployable = Deployable.generate!
      @deployment.deployable = @deployable
      @deployment.deployable.should == @deployable
    end

    it 'should have hosts' do
      @deployment.should respond_to(:hosts)
    end

    it 'should return the hosts from deployed services' do
      @deployment.deployed_services << deployed_services = Array.new(2) { DeployedService.generate! }
      @deployment.hosts.sort_by(&:id).should == deployed_services.collect(&:host).flatten.sort_by(&:id)
    end

    it 'should have an instance' do
      @deployment.should respond_to(:instance)
    end

    it "should return the deployment's instance" do
      @deployment.deployable = Deployable.generate!
      @deployment.instance.should == @deployment.deployable.instance
    end
    
    it 'should have an app' do
      @deployment.should respond_to(:app)
    end
    
    it "should return the deployable's app" do
      @deployment = Deployment.generate!
      @deployment.app.should == @deployment.deployable.app
    end
    
    it 'should have a customer' do
      @deployment.should respond_to(:customer)
    end
    
    it "should return the deployable's customer" do
      @deployment = Deployment.generate!
      @deployment.customer.should == @deployment.deployable.customer
    end
    
    it 'should have services' do
      @deployment.should respond_to(:services)
    end
    
    it "should return the deployable's services" do
      @deployment = Deployment.generate!
      @deployment.services.should == @deployment.deployable.services
    end
  end
  
  describe 'as a class' do
    it 'should be able to find active deployments' do
      Deployment.should respond_to(:active)
    end
    
    describe 'when finding active deployments' do
      before :each do
        @past = Deployment.generate!
        @past.update_attribute(:start_time,  2.days.ago)
        @past.update_attribute(:end_time, 1.day.ago)
        
        @current_closed = Deployment.generate!(:start_time => Time.now, :end_time => 1.day.from_now)
        @current_closed.update_attribute(:start_time, 2.days.ago)

        @current_open = Deployment.generate!(:start_time => Time.now, :end_time => nil)
        @current_open.update_attribute(:start_time, 2.days.ago)

        @future = Deployment.generate!(:start_time => 1.day.from_now, :end_time => 2.days.from_now)
      end
      
      it 'should work without arguments' do
        lambda { Deployment.active }.should_not raise_error(ArgumentError)
      end
      
      it 'should not complain about arguments' do
        # this is a side-effect of this being a named scope, evidently
        lambda { Deployment.active(:foo) }.should_not raise_error(ArgumentError)
      end
      
      it 'should return the empty list if there are no deployments' do
        Deployment.delete_all
        Deployment.active.should == []
      end
      
      it 'should not include past deployments in the returned list' do
        Deployment.active.should_not include(@past)
      end
      
      it 'should not include future deployments in the returned list' do
        Deployment.active.should_not include(@future)
      end
      
      it 'should include deployments with start times in the past and end times in the future' do
        Deployment.active.should include(@current_closed)
      end
      
      it 'should include deployments with start times in the past and nil end times' do
        Deployment.active.should include(@current_open)
      end
    end
  end
  
  it 'should be able to determine if it is currently active' do
    Deployment.new.should respond_to(:active?)
  end
  
  describe 'when determining if it is currently active' do
    before :each do
      @deployment = Deployment.generate!
    end
    
    it 'should work without arguments' do
      lambda { @deployment.active? }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @deployment.active?(:foo) }.should raise_error(ArgumentError)      
    end
    
    it 'should not be active if the start time is not set' do
      @deployment.start_time = nil
      @deployment.should_not be_active
    end
    
    it 'should not be active if the start time is in the future' do
      @deployment.start_time = 1.day.from_now
      @deployment.should_not be_active
    end
    
    it 'should not be active if the end time is in the past' do
      @deployment.end_time = 1.day.ago
      @deployment.should_not be_active
    end
    
    it 'should not be active if the start time is in the past and the end time is now' do
      t = Time.now
      Time.stubs(:now).returns(t)
      @deployment.start_time = 1.day.ago
      @deployment.end_time = t
      @deployment.should_not be_active
    end
    
    it 'should not be active if the start time is now and the end time is now' do
      t = Time.now
      Time.stubs(:now).returns(t)
      @deployment.start_time = t
      @deployment.end_time = t
      @deployment.should_not be_active      
    end
    
    it 'should be active if the start time is in the past and the end time is in the future' do
      @deployment.start_time = 1.day.ago
      @deployment.end_time = 1.day.from_now
      @deployment.should be_active      
    end
    
    it 'should be active if the start time is in the past and the end time is nil' do
      @deployment.start_time = 1.day.ago
      @deployment.end_time = nil
      @deployment.should be_active            
    end
    
    it 'should be active if the start time is now and the end time is in the future' do
      t = Time.now
      Time.stubs(:now).returns(t)
      @deployment.start_time = t
      @deployment.end_time = 1.day.from_now
      @deployment.should be_active                  
    end
    
    it 'should be active if the start time is now and the end time is nil' do
      t = Time.now
      Time.stubs(:now).returns(t)
      @deployment.start_time = t
      @deployment.end_time = nil
      @deployment.should be_active                        
    end
  end
end
