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
     
    it 'can be active' do
      @instance.should respond_to(:is_active)
    end
    
    it 'should allow setting and retrieving the active status' do
      @instance.is_active = true
      @instance.is_active.should be_true
    end
    
    it 'should have an app id' do
      @instance.should respond_to(:app_id)
    end
    
    it 'should allow setting and retrieving the app id' do
      @instance.app_id = 1
      @instance.app_id.should == 1
    end

    it 'should have a service id' do
      @instance.should respond_to(:service_id)
    end
    
    it 'should allow setting and retrieving the service id' do
      @instance.service_id = 1
      @instance.service_id.should == 1
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
    
    it 'should have a deployment' do
      @instance.should respond_to(:deployment)
    end
    
    it 'should allow assigning deployment' do
      @deployment = Deployment.generate!
      @instance.deployment = @deployment
      @instance.deployment.should == @deployment
    end
    
    it 'should have a host' do
      @instance.should respond_to(:host)
    end
    
    it 'should return the host for the deployment' do
      @instance = Instance.generate!
      @instance.host = @host = Host.generate!
      @instance.host.should == @host 
    end
    
    it 'should have a set of required services' do
      @instance.should respond_to(:required_services)
    end
    
    it 'should return its services when computing required services' do
      @service = Service.generate!
      @child = Service.generate!
      @service.depends_on << @child
      @instance.services << @service
      @instance.required_services.should include(@service)
    end
    
    it 'should return all services that its service depends on when computing required services' do
      @service = Service.generate!
      @child = Service.generate!
      @service.depends_on << @child
      @instance.services << @service
      @instance.required_services.should include(@child)
    end
  end
  
  it 'should be able to generate an unique name for use in a configuration' do
    Instance.new.should respond_to(:configuration_name)
  end
  
  describe 'when generating an unique name for use in a configuration' do
    before :each do
      @instance = Instance.generate!
    end
    
    it 'should work without arguments' do
      lambda { @instance.configuration_name }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @instance.configuration_name(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should not be empty' do
      @instance.configuration_name.should_not be_blank
    end
    
    it 'should vary the name when its name varies' do
      original_name = @instance.configuration_name
      @instance.name = @instance.name.succ
      @instance.configuration_name.should_not == original_name
    end
    
    it 'should vary the name when its app name varies' do
      original_name = @instance.configuration_name
      @instance.app.name = 'Something Random'
      @instance.configuration_name.should_not == original_name      
    end
    
    it 'should vary the name when its customer name varies' do
      original_name = @instance.configuration_name
      @instance.customer.name = 'Something Random'
      @instance.configuration_name.should_not == original_name      
    end
    
    it 'should include only lowercase alphanumerics and underscores' do
      @instance.name = 'Some Instance 123:::!!!'
      @instance.app.name = 'Some App 123:::!!!'
      @instance.customer.name = 'Some Customer 123:::!!!'
      @instance.configuration_name.should == 'some_customer_123__some_app_123__some_instance_123'            
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
      lambda { @instance.requirement_for(:foo) }.should_not raise_error(ArgumentError)
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
      @instance = Instance.new
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
      @instance.parameters = { :foo => :bar, :baz => :xyzzy }
      @instance.configuration_parameters.should == @instance.parameters
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

    it 'should return false if the instance has no deployment' do
      Deployment.generate!(:instance => @instance)
      @instance.safe_to_delete?.should be_false
    end
    
    it 'should return false if the instance has service requirements' do      
      @instance.requirements.generate!
      @instance.safe_to_delete?.should be_false
    end

    it 'should return true if the instance has no deployement nor service requirements' do
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
end
