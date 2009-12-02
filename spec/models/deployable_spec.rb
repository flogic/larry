require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Deployable do
  describe 'attributes' do
    before :each do
      @deployable = Deployable.spawn
    end

    it 'should have an instance id' do
      @deployable.should respond_to(:instance_id)
    end
    
    it 'should allow setting and retrieving the instance id' do
      @deployable.instance_id = 1
      @deployable.instance_id.should == 1
    end
    
    it 'should have deployment snapshot data' do
      @deployable.should respond_to(:snapshot)
    end
    
    it 'should allow setting and retrieving snapshot data' do
      @deployable.snapshot = { 'foo' => 'bar' }
      @deployable.snapshot.should == { 'foo' => 'bar' }
    end
    
    it 'should preserve snapshot data as a hash over saving' do
      @deployable.snapshot = { 'foo' => 'bar' }
      @deployable.save!
      Deployable.find(@deployable.id).snapshot.should == { 'foo' => 'bar' }
    end
    
    it 'should return an empty hash when snapshot data is empty' do
      @deployable.snapshot = nil
      @deployable.snapshot.should == {}
    end
  end
  
  describe 'validations' do
    before :each do
      @deployable = Deployable.new
    end
    
    it 'should not be valid without an instance' do
      @deployable.instance = nil
      @deployable.valid?
      @deployable.errors.should be_invalid(:instance)
    end

    it 'should be valid with an instance' do
      @deployable.instance = Instance.generate!
      @deployable.valid?
      @deployable.errors.should_not be_invalid(:instance)
    end
  end
  
  describe 'relationships' do
    before :each do
      @deployable = Deployable.generate!
    end
    
    it 'should belong to an instance' do
      @deployable.should respond_to(:instance)
    end

    it 'should allow assigning the instance' do
      @instance = Instance.generate!
      @deployable.instance = @instance
      @deployable.instance.should == @instance
    end
    
    it 'should have deployments' do
      @deployable.should respond_to(:deployments)
    end
    
    it 'should only return current deployments' do
      deployments = Array.new(2) { Deployment.generate!(:deployable => @deployable ) }
      deployments.first.update_attribute(:start_time, 1.day.from_now)
      @deployable.deployments.should == [ deployments.last ]
    end
    
    it 'should have deployed services' do
      @deployable.should respond_to(:deployed_services)
    end
    
    it "should return the current deployments' deployed services" do
      deployments = Array.new(2) { Deployment.generate!(:deployable => @deployable ) }
      deployments.first.update_attribute(:start_time, 1.day.from_now)
      non_current_deployed_services = Array.new(2) { DeployedService.generate!(:deployment => deployments.first)}
      current_deployed_services = Array.new(2) { DeployedService.generate!(:deployment => deployments.last)}
      @deployable.deployed_services.sort_by(&:id).should == current_deployed_services.sort_by(&:id)
    end
    
    it 'should have hosts' do
      @deployable.should respond_to(:hosts)
    end
    
    it "should return the current deployments' hosts" do
      deployments = Array.new(2) { Deployment.generate!(:deployable => @deployable ) }
      deployments.first.update_attribute(:start_time, 1.day.from_now)
      non_current_deployed_services = Array.new(2) { DeployedService.generate!(:deployment => deployments.first)}
      current_deployed_services = Array.new(2) { DeployedService.generate!(:deployment => deployments.last)}
      @deployable.hosts.sort_by(&:id).should == current_deployed_services.collect(&:host).sort_by(&:id)
    end
    
    it 'should have an app' do
      @deployable.should respond_to(:app)
    end
    
    it "should return the instance's app" do
      @deployable = Deployable.generate!
      @deployable.app.should == @deployable.instance.app
    end
    
    it 'should have a customer' do
      @deployable.should respond_to(:customer)
    end
    
    it "should return the app's customer" do
      @deployable = Deployable.generate!
      @deployable.customer.should == @deployable.app.customer
    end
    
    it 'should have services' do
      @deployable.should respond_to(:services)
    end
    
    it "should return the instance's services when looking up the service" do
      @deployable = Deployable.generate!
      @deployable.services.should == @deployable.instance.services
    end
  end
end
