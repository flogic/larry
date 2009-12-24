require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Instance do
  describe 'attributes' do
    before :each do
      @instance = Instance.new
    end

    it 'can have a name' do
      @instance.should respond_to(:name)
    end
    
    it 'should allow setting and retrieving the name' do
      @instance.name = 'Test Instance'
      @instance.name.should == 'Test Instance'
    end
    
    it 'can have a description' do
      @instance.should respond_to(:description)
    end
    
    it 'should allow setting and retrieving the description' do
      @instance.description = 'Test Instance Description'
      @instance.description.should == 'Test Instance Description'
    end
     
    it 'should have an app id' do
      @instance.should respond_to(:app_id)
    end
    
    it 'should allow setting and retrieving the app id' do
      @instance.app_id = 1
      @instance.app_id.should == 1
    end

    it 'should have a set of parameters' do
      @instance.should respond_to(:parameters)
    end
    
    it 'should allow setting and retrieving parameter values' do
      @instance.parameters = { :foo => 'bar' }
      @instance.parameters[:foo].should == 'bar'
    end
    
    it 'should preserve parameters as a hash across saving' do
      @instance = Instance.generate!(:parameters => { :foo => 'bar'})
      Instance.find(@instance.id).parameters[:foo].should == 'bar'
    end
    
    it 'should return an empty hash for parameters when parameters is empty' do
      @instance.parameters = nil
      @instance.parameters.should == {}
    end
  end
  
  describe 'validations' do
    before :each do
      @instance = Instance.new
    end
    
    it 'should not be valid without an app' do
      @instance.app = nil
      @instance.valid?
      @instance.errors.should be_invalid(:app)
    end

    it 'should be valid with an app' do
      @instance.app = App.generate!
      @instance.valid?
      @instance.errors.should_not be_invalid(:app)
    end

    it 'should not be valid without a name' do
      @instance.name = nil
      @instance.valid?
      @instance.errors.should be_invalid(:name)
    end
    
    it 'should not be valid with a duplicate name within the scope of its app' do
      other = Instance.generate!
      @instance = Instance.spawn(:app => other.app)
      @instance.name = other.name
      @instance.valid?
      @instance.errors.should be_invalid(:name)
    end
    
    it 'should be valid with a duplicate name that is unique within the scope of its app' do
      other = Instance.generate!
      @instance = Instance.spawn
      @instance.name = other.name
      @instance.valid?
      @instance.errors.should_not be_invalid(:name)
    end
  end
  
  describe 'relationships' do
    before :each do
      @instance = Instance.new
    end
    
    it 'should belong to an app' do
      @instance.should respond_to(:app)
    end

    it 'should allow assigning the app' do
      @app = App.generate!
      @instance.app = @app
      @instance.app.should == @app
    end
    
    it 'should have many services' do
      @instance.should respond_to(:services)
    end
    
    it 'should allow assigning services' do
      @service = Service.generate!
      @instance.services << @service
      @instance.services.should include(@service)
    end
    
    it 'should have a customer' do
      @instance.should respond_to(:customer)
    end
    
    it 'should return the app customer' do
      @instance = Instance.generate!
      @instance.customer.should == @instance.app.customer
    end
    
    it 'should have deployables' do
      @instance.should respond_to(:deployables)
    end
    
    it 'should allow setting and retrieving deployables' do
      @deployables = Array.new(2) { Deployable.generate! }
      @instance.deployables << @deployables
      @instance.deployables.should == @deployables
    end
    
    it 'should have deployments' do
      @instance.should respond_to(:deployments)
    end
    
    it 'should return the deployments from our deployables' do
      deployments = Array.new(2) { Deployment.generate! }
      @instance.deployables << deployments.collect(&:deployable)
      @instance.deployments.sort_by(&:id).should == deployments.sort_by(&:id)
    end
    
    it 'should return only current deployments' do
      deployments = Array.new(2) { Deployment.generate! }
      @instance.deployables << deployments.collect(&:deployable)
      deployments.first.update_attribute(:start_time, 1.day.from_now)
      @instance.deployments.should == [ deployments.last ]
    end
    
    it 'should have hosts' do
      @instance.should respond_to(:hosts)
    end
    
    it 'should return the hosts from our deployments' do
      deployed_services = Array.new(2) { DeployedService.generate! }
      @instance.deployables << deployed_services.collect(&:deployable)
      @instance.hosts.sort_by(&:id).should == deployed_services.collect(&:host).sort_by(&:id)
    end
    
    it 'should return only current hosts' do
      deployed_services = Array.new(2) { DeployedService.generate! }
      @instance.deployables << deployed_services.collect(&:deployable)
      deployed_services.first.deployment.update_attribute(:start_time, 1.day.from_now)
      @instance.hosts.should == [ deployed_services.last.host ]
    end
  end
  
  describe 'providing access to non-current data' do
    before :each do
      @instance = Instance.new

      @past = DeployedService.generate!
      @past.deployment.update_attribute(:start_time, 2.days.ago)
      @past.deployment.update_attribute(:end_time, 1.day.ago)
      @current = DeployedService.generate!
      @current.deployment.update_attribute(:start_time, 2.days.ago)
      @future = DeployedService.generate!
      @future.deployment.update_attribute(:start_time, 1.day.from_now)
      @all = [@past, @current, @future]
      @instance.deployables << @all.collect(&:deployable)
    end
    
    it 'should be able to find all deployments' do
      @instance.all_deployments.sort_by(&:id).should == @all.collect(&:deployment).sort_by(&:id)        
    end
    
    it 'should be able to find all deployed services' do
      @instance.all_deployed_services.sort_by(&:id).should == @all.sort_by(&:id)        
    end
    
    it 'should be able to find all hosts' do
      @instance.all_hosts.sort_by(&:id).should == @all.collect(&:host).sort_by(&:id)        
    end
  end
  
  it 'should be able to locate a requirement for a service' do
    Instance.new.should respond_to(:requirement_for)
  end
  
  describe 'when locating a requirement for a service' do
    before :each do
      @instance = Instance.generate!
    end
    
    it 'should accept a service' do 
      lambda { @instance.requirement_for(@instance) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a service' do
      lambda { @instance.requirement_for }.should raise_error(ArgumentError)
    end
    
    it 'should return nil when the service cannot be found' do
      @instance.requirement_for(Service.new).should be_nil
    end
    
    it 'should return the requirement instance that is associated with this instance and the provided service' do
      service = Service.generate!
      @instance.services << service
      result = @instance.requirement_for(service)
      result.instance.should == @instance
      result.service.should == service
    end
  end  
  
  it 'should be able to find a set of unrelated services' do
    Instance.new.should respond_to(:unrelated_services)
  end
  
  describe 'when finding a set of unrelated services' do
    before :each do
      @instance = Instance.new
    end
    
    it 'should not require any arguments' do
      lambda { @instance.unrelated_services }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow any arguments' do
      lambda { @instance.unrelated_services(:foo) }.should raise_error(ArgumentError)
    end
    
    it "should ask for the list of services unrelated to this instance's required services" do
      Service.expects(:unrelated_services).with(@instance.services)
      @instance.unrelated_services
    end
    
    it "should return the list of services unrelated to this instance's required services" do
      Service.stubs(:unrelated_services).with(@instance.services).returns('foo')
      @instance.unrelated_services.should == 'foo'
    end
  end
  
  it 'should be able to generate a set of configuration parameters' do
    Instance.new.should respond_to(:configuration_parameters)
  end
  
  describe 'when generating a set of configuration parameters' do
    before :each do
      @instance = Instance.generate!(:parameters => {:foo => :bar, :baz => :xyzzy })
    end
    
    it 'should work without arguments' do
      lambda { @instance.configuration_parameters }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @instance.configuration_parameters(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should be a hash' do
      @instance.configuration_parameters.should respond_to(:keys)
    end
    
    it "should return an empty hash when the instance's parameters are empty" do
      @instance.parameters = nil
      @instance.configuration_parameters.should == {}
    end
    
    it "should return the instance's parameters when the parameters are not empty" do
      @instance.configuration_parameters.should == @instance.parameters
    end
    
    it 'should use app parameters as defaults when available' do
      @instance.app.parameters = { :missing => :value }
      @instance.configuration_parameters[:missing].should == :value
    end
    
    it 'should always override app parameters with our parameters' do
      @instance.app.parameters = { :missing => :value }
      @instance.parameters[:missing] = :ours
      @instance.configuration_parameters[:missing].should == :ours
    end
    
    it 'should use customer parameters as defaults when available' do
      @instance.customer.parameters = { :missing => :value }
      @instance.configuration_parameters[:missing].should == :value
    end
    
    it 'should always override customer parameters with app parameters' do
      @instance.customer.parameters = { :missing => :value }
      @instance.app.parameters = { :missing => :app }
      @instance.configuration_parameters[:missing].should == :app
    end

    it 'should always override customer parameters with our parameters' do
      @instance.customer.parameters = { :missing => :value }
      @instance.parameters = { :missing => :our }
      @instance.configuration_parameters[:missing].should == :our
    end
  end
  
  it 'should have a means to determine if it is safe to delete this instance' do
    Instance.new.should respond_to(:safe_to_delete?)
  end

  describe 'when determining if it is safe to delete this instance' do
    before :each do
      @instance = Instance.generate!
    end

    it 'should work without arguments' do
      lambda { @instance.safe_to_delete? }.should_not raise_error(ArgumentError)
    end

    it 'should not accept arguments' do
      lambda { @instance.safe_to_delete?(:foo) }.should raise_error(ArgumentError)      
    end

    it 'should return false if the instance has deployables' do
      Deployable.generate!(:instance => @instance)
      @instance.safe_to_delete?.should be_false
    end
    
    it 'should return false if the instance has service requirements' do      
      @instance.requirements.generate!
      @instance.safe_to_delete?.should be_false
    end

    it 'should return true if the instance has no deployables nor service requirements' do
      @instance.safe_to_delete?.should be_true
    end
  end

  describe 'when deleting' do
    before :each do
      @instance = Instance.generate!
    end

    it 'should not allow deletion when it is not safe to delete' do
      @instance.stubs(:safe_to_delete?).returns(false)
      lambda { @instance.destroy }.should_not change(Instance, :count)
    end

    it 'should allow deletion when it is safe to delete' do
      @instance.stubs(:safe_to_delete?).returns(true)
      lambda { @instance.destroy }.should change(Instance, :count)    
    end
  end
  
  it 'should be able to retrieve the list of parameters needed by our required services' do
    Instance.new.should respond_to(:needed_parameters)
  end
  
  describe 'when retrieving the list of parameters needed by our required services' do
    before :each do
      @instance = Instance.generate!
    end
      
    it 'should work without arguments' do 
      lambda { @instance.needed_parameters }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @instance.needed_parameters(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should return the empty list if there are no required services' do
      @instance.needed_parameters.should == []
    end
    
    it 'should return the empty list if required services have no needed parameters' do
      @instance.services << Array.new(2) { Service.generate! }
    end
    
    it 'should return the list of parameters needed by required services' do
      @instance.services << services = Array.new(3) { Service.generate! }
      services.first.parameters = [ 'field 1', 'field 2' ]
      services.last.parameters = [ 'field 3', 'field 4' ]
      services.first.save!
      services.last.save!
      @instance.needed_parameters.sort.should == [ 'field 1', 'field 2', 'field 3', 'field 4' ]
    end
    
    it 'should not include duplicates in the list of parameters needed by required services' do
      @instance.services << services = Array.new(3) { Service.generate! }
      services.first.parameters = [ 'field 1', 'field 2' ]
      services.last.parameters = [ 'field 2', 'field 3' ]
      services.first.save!
      services.last.save!
      @instance.needed_parameters.sort.should == [ 'field 1', 'field 2', 'field 3' ]
    end
    
    it 'should not include empty values in the list of parameters needed by required services' do
      @instance.services << services = Array.new(3) { Service.generate! }
      services.first.parameters = [ 'field 1', 'field 2' ]
      services.last.parameters = [ 'field 2', nil ]
      services.first.save!
      services.last.save!
      @instance.needed_parameters.sort.should == [ 'field 1', 'field 2' ]
    end
    
    it 'should include parameters needed by services our required services depend on' do
      @instance.services << services = Array.new(3) { Service.generate! }
      services.first.parameters = [ 'field 1', 'field 2' ]
      services.last.parameters = [ 'field 2', 'field 3' ]
      services.first.save!
      services.last.save!
      kid = Service.generate!(:parameters => [ 'field 4' ])
      services.last.depends_on << kid
      @instance.needed_parameters.sort.should == [ 'field 1', 'field 2', 'field 3', 'field 4' ]      
    end
  end
  
  it 'should be able to return those parameter keys of ours which match service parameter requirements' do
    Instance.new.should respond_to(:matching_parameters)
  end
  
  describe 'when returning matching parameters' do
    before :each do
      @parameters = { 
        'matching 1' => 'value 1', 
        'matching 2' => 'value 2',
        'unknown 3'  => 'value 3' 
      }
      @instance = Instance.generate!()
      @service = Service.generate!(:parameters => [ 'matching 1', 'matching 2', 'missing 3' ])
      @instance.services << @service
    end
    
    it 'should work without arguments' do
      lambda { @instance.matching_parameters }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @instance.matching_parameters(:foo) }.should raise_error(ArgumentError)
    end

    it 'should return an empty hash when there are no service parameter requirements' do
      @service.parameters = []
      @instance.matching_parameters.should == { }
    end
    
    it 'should return an empty hash when none of our parameters match service parameter requirements' do
      @instance.parameters = { 'unknown 3' => 'value 3' }
      @instance.matching_parameters.should == { }
    end
    
    it 'should return a hash with pairs matching service parameter requirements' do
      @instance.parameters = @parameters
      @instance.matching_parameters.should == { 
        'matching 1' => 'value 1', 
        'matching 2' => 'value 2',
      }      
    end
  end
  
  it 'should be able to return those service parameter names which are required but which we are missing' do
    Instance.new.should respond_to(:missing_parameters)    
  end
  
  describe 'when returning missing parameters' do
    before :each do
      @parameters = { 
        'matching 1' => 'value 1', 
        'matching 2' => 'value 2',
        'unknown 3'  => 'value 3' 
      }
      @instance = Instance.generate!()
      @service = Service.generate!(:parameters => [ 'matching 1', 'matching 2', 'missing 3' ])
      @instance.services << @service
    end
    
    it 'should work without arguments' do
      lambda { @instance.missing_parameters }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @instance.missing_parameters(:foo) }.should raise_error(ArgumentError)
    end

    it 'should return an empty list when there are no service parameter requirements' do
      @service.parameters = []
      @service.save!
      @instance.missing_parameters.should == []
    end
    
    it 'should return an empty list when our parameters all match service parameter requirements' do
      @instance.parameters = { 'matching 1' => 'value 1', 'matching 2' => 'value 2' }
      @service.parameters = [ 'matching 1', 'matching 2']
      @service.save!
      @instance.missing_parameters.should == []
    end
    
    it 'should return a list of service-required parameter names missing from our parameters' do
      @instance.parameters = @parameters
      @instance.missing_parameters.should == [ 'missing 3' ]
    end
  end
  
  it 'should be able to return those parameter keys of ours which do not match service parameter requirements' do |variable|
    Instance.new.should respond_to(:unknown_parameters)
  end
  
  describe 'when returning unknown parameters' do
    before :each do
      @parameters = { 
        'matching 1' => 'value 1', 
        'matching 2' => 'value 2',
        'unknown 3'  => 'value 3' 
      }
      @instance = Instance.generate!()
      @service = Service.generate!(:parameters => [ 'matching 1', 'matching 2', 'missing 3' ])
      @instance.services << @service
    end
    
    it 'should work without arguments' do
      lambda { @instance.unknown_parameters }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @instance.unknown_parameters(:foo) }.should raise_error(ArgumentError)
    end

    it 'should return an empty hash when there are no parameters' do
      @instance.parameters = {}
      @instance.unknown_parameters.should == {}
    end
    
    it 'should return an empty hash when our parameters all match service parameter requirements' do
      @instance.parameters = { 'matching 1' => 'value 1', 'matching 2' => 'value 2' }
      @service.parameters = [ 'matching 1', 'matching 2']
      @service.save!
      @instance.unknown_parameters.should == {}
    end
    
    it 'should return a hash of parameter pairs which are not required by our services' do
      @instance.parameters = @parameters
      @instance.unknown_parameters.should == { 'unknown 3' => 'value 3' }
    end
  end
  
  it 'should have an indicator for whether or not it can be deployed' do
    Instance.new.should respond_to(:can_deploy?)
  end
  
  describe 'when checking whether the instance can be deployed' do
    before :each do
      @instance = Instance.generate!
    end
    
    it 'should work without arguments' do
      lambda { @instance.can_deploy? }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @instance.can_deploy?(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should return false if it has no services' do
      @instance.can_deploy?.should be_false
    end
    
    it 'should return false if it has services but no service-required parameters' do
      @instance.services << Service.generate!
      @instance.can_deploy?.should be_true
    end
    
    it 'should return true if all service-required parameters have values' do
      @instance.services << services = Array.new(3) { Service.generate! }
      services.first.parameters = [ 'field 1', 'field 2' ]
      services.last.parameters = [ 'field 3', 'field 4' ]
      services.first.save!
      services.last.save!
      @instance.parameters = { 
        'field 1' => 'value 1', 'field 2' => 'value 2',
        'field 3' => 'value 3', 'field 4' => 'value 4',
      }
      @instance.can_deploy?.should be_true
    end
    
    it 'should return true if an app parameter settings fulfill missing service-required parameter values' do
      @instance.services << services = Array.new(3) { Service.generate! }
      services.first.parameters = [ 'field 1', 'field 2' ]
      services.last.parameters = [ 'field 3', 'field 4' ]
      services.first.save!
      services.last.save!
      @instance.parameters = { 'field 1' => 'value 1', 'field 2' => 'value 2', 'field 3' => 'value 3' }
      @instance.app.parameters = { 'field 4' => 'value 4' }
      @instance.can_deploy?.should be_true      
    end
    
    it 'should return true if a customer parameter settings fulfill missing service-required parameter values' do
      @instance.services << services = Array.new(3) { Service.generate! }
      services.first.parameters = [ 'field 1', 'field 2' ]
      services.last.parameters = [ 'field 3', 'field 4' ]
      services.first.save!
      services.last.save!
      @instance.parameters = { 'field 1' => 'value 1', 'field 2' => 'value 2', 'field 3' => 'value 3' }
      @instance.customer.parameters = { 'field 4' => 'value 4' }
      @instance.can_deploy?.should be_true      
    end
    
    it 'should return false if some service-required parameters are without values' do
      @instance.services << services = Array.new(3) { Service.generate! }
      services.first.parameters = [ 'field 1', 'field 2' ]
      services.last.parameters = [ 'field 3', 'field 4' ]
      services.first.save!
      services.last.save!
      @instance.parameters = { 'field 1' => 'value 1', 'field 2' => 'value 2', 'field 3' => 'value 3' }
      @instance.can_deploy?.should be_false
    end
  end

  it 'should be able to tell where a parameter setting comes from' do
    Instance.new.should respond_to(:parameter_whence)
  end
  
  describe 'when finding where a parameter setting comes from' do
    before :each do
      @instance = Instance.generate!(:parameters => { 'instance' => 'instance match' })
    end
    
    it 'should allow a parameter name' do
      lambda { @instance.parameter_whence('foo') }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a parameter name' do
      lambda { @instance.parameter_whence }.should raise_error(ArgumentError)
    end
    
    it 'should return nil if the parameter is not set' do
      @instance.parameter_whence('missing').should be_nil
    end
    
    it 'should return nil if the parameter is set in the instance' do
      @instance.parameter_whence('instance').should be_nil      
    end
    
    it 'should return the app if the parameter is set in the app but not the instance' do
      @instance.app.parameters = { 'app' => 'app match' }
      @instance.parameter_whence('app').should == @instance.app            
    end
    
    it 'should return the customer if the parameter is set in the customer but not the app or the instance' do
      @instance.customer.parameters = { 'customer' => 'customer match' }
      @instance.parameter_whence('customer').should == @instance.customer                  
    end
  end
  
  it 'should be able to be deployed' do
    Instance.new.should respond_to(:deploy)
  end
  
  describe 'deploy' do
    before :each do
      @deployable = Deployable.generate!
      @host = Host.generate!
      @instance = @deployable.instance
      @parameters = @deployable.attributes.merge(:host_id => @host.id, :start_time => Time.now, :reason => 'Because.')
    end
    
    it 'should allow parameters' do
      lambda { @instance.deploy(@parameters) }.should_not raise_error(ArgumentError)
    end
    
    it 'should allow parameters and a deployable' do
      lambda { @instance.deploy(@parameters, @deployable) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not work without parameters' do
      lambda { @instance.deploy }.should raise_error(ArgumentError)
    end
    
    describe 'when a deployable is specified' do
      it 'should fail if the deployable is not associated with the instance' do
        lambda { @instance.deploy(@params, Deployable.generate!) }.should raise_error(ArgumentError)
      end
      
      it 'should deploy the deployable with the provided params' do
        @deployable.expects(:deploy).with(@params)
        @deployable.instance.deploy(@params, @deployable)
      end
      
      it 'should return the result of deploying the deployable' do
        @deployable.stubs(:deploy).with(@params).returns('result')
        @deployable.instance.deploy(@params, @deployable).should == 'result' 
      end
    end
    
    describe 'when no deployable is specified' do
      it 'should create a new deployable' do
        lambda { @instance.deploy(@parameters) }.should change(Deployable, :count)
      end
      
      it 'should associate the new deployable with the instance' do
        @instance.deploy(@parameters)
        @instance.deployables.should_not be_empty
      end
      
      it 'should deploy the new deployable with the provided params' do
        Deployable.expects(:deploy_from_instance).with(@instance, @parameters)
        @instance.deploy(@parameters)
      end
      
      it 'should return the result of deploying the new deployable' do
        Deployable.stubs(:deploy_from_instance).with(@instance, @parameters).returns('result')
        @instance.deploy(@parameters).should == 'result'
      end
    end
  end
  
  it 'should be able to compute all the services needed to deploy this instance' do
    Instance.new.should respond_to(:all_required_services)
  end
  
  describe 'when computing all the services needed to deploy this instance' do
    before :each do
      @instance = Instance.generate!
    end
    
    it 'should work without arguments' do
      lambda { @instance.all_required_services }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do      
      lambda { @instance.all_required_services(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should return the empty list if we require no services' do
      @instance.all_required_services.should == []
    end
    
    it 'should return all the services we require' do
      @instance.services << services = Array.new(2) { Service.generate! }
      @instance.all_required_services.sort_by(&:id).should == services.sort_by(&:id)
    end
    
    it 'should return all the services that our required services depend on' do
      kid1 = Service.generate!
      kid1.depends_on << grandkids1 = Array.new(2) { Service.generate! }
      kid2 = Service.generate!
      kid2.depends_on << grandkids2 = Array.new(2) { Service.generate! }
      services = [ kid1, kid2 ]
      all_services = services + grandkids1 + grandkids2
      @instance.services << services
      result = @instance.all_required_services
      all_services.each {|service| result.should include(service) }
    end
    
    it 'should not include duplicate services' do
      kid1 = Service.generate!
      kid2 = Service.generate!
      grandkids = Array.new(2) { Service.generate! }
      kid1.depends_on << grandkids
      kid2.depends_on << grandkids
      services = [ kid1, kid2 ]
      @instance.services << services
      all_services = grandkids << kid1 << kid2
      @instance.all_required_services.sort_by(&:id).should == all_services.sort_by(&:id)
    end
  end
end
