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
  
  describe 'as a class' do
    it 'should be able to deploy an instance' do
      Deployable.should respond_to(:deploy_from_instance)
    end
    
    describe 'when deploying an instance' do
      before :each do
        @instance = Instance.generate!
        @parameters = Deployment.generate!.attributes.merge(:start_time => Time.now, :reason => 'Because')
      end
      
      it 'should allow specifying an instance and deployment parameters' do
        lambda { Deployable.deploy_from_instance(@instance, @parameters) }.should_not raise_error(ArgumentError)
      end
      
      it 'should require both an instance and deployment parameters' do
        lambda { Deployable.deploy_from_instance(@instance) }.should raise_error(ArgumentError)
      end
      
      it 'should create a new deployable' do
        lambda { Deployable.deploy_from_instance(@instance, @parameters) }.should change(Deployable, :count)
      end
      
      it 'should associate the instance with the new deployable' do
        Deployable.delete_all
        Deployable.deploy_from_instance(@instance, @parameters)
        Deployable.first.instance.should == @instance
      end
      
      it 'should deploy the newly created deployable with the deployment parameters' do
        deployable = {}
        Deployable.stubs(:create!).returns(deployable)
        deployable.expects(:deploy).with(@parameters)
        Deployable.deploy_from_instance(@instance, @parameters)
      end
      
      it 'should return the result of deploying' do
        deployable = {}
        Deployable.stubs(:create!).returns(deployable)
        deployable.stubs(:deploy).returns('deployed')
        Deployable.deploy_from_instance(@instance, @parameters).should == 'deployed'
      end
    end
  end
  
  it 'should be able to deploy' do
    Deployable.new.should respond_to(:deploy)
  end
  
  describe 'when deploying' do
    before :each do
      @deployable = Deployable.generate!
      @deployment = Deployment.generate!
      @parameters = @deployment.attributes.merge(:start_time => Time.now, :reason => 'Because.')
    end
    
    it 'should allow specifying deployment parameters' do
      lambda { @deployable.deploy(@parameters) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require deployment parameters' do
      lambda { @deployable.deploy }.should raise_error(ArgumentError)
    end
    
    it 'should create a deployment' do
      lambda { @deployable.deploy(@parameters) }.should change(Deployment, :count)
    end
    
    it 'should associate the new deployment with this deployable' do
      Deployment.delete_all
      @deployable.deploy(@parameters)
      @deployable.deployments.should == [ Deployment.first ]
    end
    
    it 'should deploy the new deployment with the deployment parameters' do
      Deployment.expects(:deploy_from_deployable).with(@deployable, @parameters)
      @deployable.deploy(@parameters)
    end
    
    it 'should return the result of deploying the new deployment' do
      Deployment.stubs(:deploy_from_deployable).returns('deployed')
      @deployable.deploy(@parameters).should == 'deployed'     
    end
  end
  
  describe 'providing access to non-current data' do
    before :each do
      @deployable = Deployable.new

      @past = DeployedService.generate!
      @past.deployment.update_attribute(:start_time, 2.days.ago)
      @past.deployment.update_attribute(:end_time, 1.day.ago)
      @past.deployment.update_attribute(:deployable_id, @deployable.id)
      @current = DeployedService.generate!
      @current.deployment.update_attribute(:start_time, 2.days.ago)
      @current.deployment.update_attribute(:deployable_id, @deployable.id)
      @future = DeployedService.generate!
      @future.deployment.update_attribute(:start_time, 1.day.from_now)
      @future.deployment.update_attribute(:deployable_id, @deployable.id)
      @all = [@past, @current, @future]
      @deployable.all_deployments << @all.collect(&:deployment)
    end
    
    it 'should be able to find all deployments' do
      @deployable.all_deployments.sort_by(&:id).should == @all.collect(&:deployment).sort_by(&:id)        
    end
    
    it 'should be able to find all deployed services' do
      @deployable.all_deployed_services.sort_by(&:id).should == @all.sort_by(&:id)        
    end
    
    it 'should be able to find all hosts' do
      @deployable.all_hosts.sort_by(&:id).should == @all.collect(&:host).sort_by(&:id)        
    end
  end
  
  it 'should provide a means of returning the parameter settings for a service' do
    Deployable.new.should respond_to(:service_parameters)
  end
  
  describe 'when returning the parameter settings for a service' do
    before :each do
      @deployable = Deployable.generate!
      @deployable.instance.requirements.generate!  # create a Service Requirement for our Instance
      @service = @deployable.services.first
    end
    
    it 'should accept a service name' do
      lambda { @deployable.service_parameters('foo') }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a service name' do
      lambda { @deployable.service_parameters }.should raise_error(ArgumentError)
    end
    
    it 'should return an empty hash if the service is not known' do
      @deployable.service_parameters('unknown service').should == {}
    end
    
    it "should return our instance's configuration parameter settings for the service's required parameters" do
      @deployable.instance.update_attribute(:parameters, {'known 1' => 'val 1', 'known 2' => 'val 2', 'missing 3' => 'val 3'})
      @service.update_attribute(:parameters, [ 'known 1', 'known 2' ])
      @deployable.service_parameters(@service.name).should == {'known 1' => 'val 1', 'known 2' => 'val 2' }
    end
  end
end
