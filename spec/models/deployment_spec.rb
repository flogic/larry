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
end
