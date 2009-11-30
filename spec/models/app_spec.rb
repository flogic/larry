require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe App do
  describe 'attributes' do
    before :each do
      @app = App.new
    end
    
    it 'should have a name' do
      @app.should respond_to(:name)
    end
    
    it 'should allow setting and retrieving the name' do
      @app.name = 'test name'
      @app.name.should == 'test name'
    end

    it 'should have a description' do
      @app.should respond_to(:description)
    end

    it 'should allow setting and retrieving the description' do
      @app.description = 'test description'
      @app.description.should == 'test description'
    end
    
    it 'should have a customer id' do
      @app.should respond_to(:customer_id)
    end
    
    it 'should allow setting and retrieving the customer id' do
      @app.customer_id = 1
      @app.customer_id.should == 1
    end
    
    it 'should have a set of parameters' do
      @app.should respond_to(:parameters)
    end
    
    it 'should allow setting and retrieving parameter values' do
      @app.parameters = { :foo => 'bar' }
      @app.parameters[:foo].should == 'bar'
    end
    
    it 'should preserve parameters as a hash across saving' do
      @app = App.generate!(:parameters => { :foo => 'bar'})
      App.find(@app.id).parameters[:foo].should == 'bar'
    end
    
    it 'should return an empty hash for parameters when parameters are blank' do
      @app.parameters = nil
      @app.parameters.should == {}
    end
  end

  describe 'validations' do
    before :each do
      @app = App.new
    end

    it 'should require a name' do
      @app.name = nil
      @app.valid?
      @app.errors.should be_invalid(:name)
    end
    
    it 'should be valid with a name' do
      @app.name = 'Test Name'
      @app.valid?
      @app.errors.should_not be_invalid(:name)
    end
    
    it 'should not be valid without a name' do
      @app.name = nil
      @app.valid?
      @app.errors.should be_invalid(:name)
    end

    it 'should not be valid with a duplicate name within the scope of its customer' do
      other = App.generate!
      @app = App.spawn(:customer => other.customer)
      @app.name = other.name
      @app.valid?
      @app.errors.should be_invalid(:name)
    end
    
    it 'should be valid with a duplicate name that is unique within the scope of its customer' do
      other = App.generate!
      @app = App.spawn
      @app.name = other.name
      @app.valid?
      @app.errors.should_not be_invalid(:name)
    end    
    
    it 'should not be valid without a customer' do
      @app.customer = nil
      @app.valid?
      @app.errors.should be_invalid(:customer)
    end

    it 'should be valid with a customer' do
      @app.customer = Customer.generate!
      @app.valid?
      @app.errors.should_not be_invalid(:customer)
    end  
  end
  
  describe 'relationships' do
    before :each do
      @app = App.new
    end
    
    it 'should belong to a customer' do
      @app.should respond_to(:customer)
    end

    it 'should allow assigning customer' do
      customer = Customer.generate!
      @app.customer = customer
      @app.customer.should == customer
    end
    
    it 'should have many instances' do
      @app.should respond_to(:instances)
    end
    
    it 'should allow assigning instances' do
      instance = Instance.generate!
      @app.instances << instance
      @app.instances.should include(instance)
    end
    
    it 'should have many deployments' do
      @app.should respond_to(:deployments)
    end
    
    it "should allow return instances' deployments" do
      deployed_services = Array.new(2) { DeployedService.generate! }
      @app.instances << deployed_services.collect(&:instance)
      @app.deployments.sort_by(&:id).should == @app.instances.collect(&:deployments).flatten.sort_by(&:id)
    end
    
    it 'should have many deployables' do
      @app.should respond_to(:deployables)
    end
    
    it "should allow return instances' deployables" do
      deployed_services = Array.new(2) { DeployedService.generate! }
      @app.instances << deployed_services.collect(&:instance)
      @app.deployables.sort_by(&:id).should == @app.instances.collect(&:deployables).flatten.sort_by(&:id)
    end
    
    it 'should have many deployed services' do
      @app.should respond_to(:deployments)
    end
    
    it "should allow return instances' deployed services" do
      deployed_services = Array.new(2) { DeployedService.generate! }
      @app.instances << deployed_services.collect(&:instance)
      @app.deployed_services.sort_by(&:id).should == @app.instances.collect(&:deployed_services).flatten.sort_by(&:id)
    end
    
    it 'should have many hosts' do
      @app.should respond_to(:hosts)
    end
    
    it "should return instances' hosts" do
      deployed_services = Array.new(2) { DeployedService.generate! }
      @app.instances << deployed_services.collect(&:instance)
      @app.hosts.sort_by(&:id).should == @app.instances.collect(&:hosts).flatten.sort_by(&:id)
    end
    
    it 'should have services' do
      @app.should respond_to(:services)
    end
    
    it 'should return the services from all instances when computing services' do
      @instances = Array.new(2) { Instance.generate! }
      @app.instances << @instances
      @app.services.sort_by(&:id).should == @instances.collect(&:services).flatten.sort_by(&:id)
    end
  end
  
  it 'should have a means to determine if it is safe to delete this app' do
    App.new.should respond_to(:safe_to_delete?)
  end
  
  describe 'when determining if it is safe to delete this app' do
    before :each do
      @app = App.generate!
    end
    
    it 'should work without arguments' do
      lambda { @app.safe_to_delete? }.should_not raise_error(ArgumentError)
    end
    
    it 'should not accept arguments' do
      lambda { @app.safe_to_delete?(:foo) }.should raise_error(ArgumentError)      
    end
    
    it 'should return false if the app has instances' do
      @app.instances.generate!
      @app.safe_to_delete?.should be_false
    end
    
    it 'should return true if the app has no instances' do
      @app.safe_to_delete?.should be_true
    end
  end
  
  describe 'when deleting' do
    before :each do
      @app = App.generate!
    end
    
    it 'should not allow deletion when it is not safe to delete' do
      @app.stubs(:safe_to_delete?).returns(false)
      lambda { @app.destroy }.should_not change(App, :count)
    end
  
    it 'should allow deletion when it is safe to delete' do
      @app.stubs(:safe_to_delete?).returns(true)
      lambda { @app.destroy }.should change(App, :count)    
    end
  end
end
