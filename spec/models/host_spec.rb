require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Host do
  describe 'attributes' do
    before :each do
      @host = Host.new
    end
    
    it 'should have a name' do
      @host.should respond_to(:name)
    end
    
    it 'should allow setting and retrieving the name' do
      @host.name = 'test name'
      @host.name.should == 'test name'
    end

    it 'should have a description' do
      @host.should respond_to(:description)
    end

    it 'should allow setting and retrieving the description' do
      @host.description = 'test description'
      @host.description.should == 'test description'
    end
  end

  describe 'validations' do
    before :each do
      @host = Host.new
    end

    it 'should require a name' do
      @host.name = nil
      @host.valid?
      @host.errors.should be_invalid(:name)
    end
    
    it 'should require name to be unique' do
      dup = Host.generate!(:name => 'unoriginal name')
      @host.name = 'unoriginal name'
      @host.valid?
      @host.errors.should be_invalid(:name)
    end

    it 'should be valid with an unique name' do
      @host.name = 'creative name'
      @host.valid?
      @host.errors.should_not be_invalid(:name)
    end
  end

  describe 'relationships' do
    before :each do
      @host = Host.new
    end

    it 'should have many deployments' do
      @host.should respond_to(:deployments)
    end

    it 'should allow assigning deployments' do
      @deployment = Deployment.generate!
      @host.deployments << @deployment
      @host.deployments.should include(@deployment)
    end
    
    it 'should have many instances' do
      @host.should respond_to(:instances)
    end
    
    it 'should allow assigning instances' do
      @instance = Instance.generate!
      @host.instances << @instance
      @host.instances.should include(@instance)
    end
    
    it 'should have many apps' do
      @host.should respond_to(:apps)
    end
    
    it 'should include apps from all deployments' do
      @deployments = Array.new(2) { Deployment.generate! }
      @host.deployments << @deployments
      @host.apps.sort_by(&:id).should == @deployments.collect(&:app).sort_by(&:id)
    end
    
    it 'should have many customers' do
      @host.should respond_to(:customers)
    end

    it 'should include customers from all deployments' do
      @deployments = Array.new(2) { Deployment.generate! }
      @host.deployments << @deployments
      @host.customers.sort_by(&:id).should == @deployments.collect(&:customer).flatten.sort_by(&:id)      
    end
  end
  
  it 'should be able to compute a configuration' do
    Host.new.should respond_to(:configuration)
  end
  
  describe 'when computing a configuration' do
    before :each do
      @host = Host.generate!
    end
    
    it 'should work without arguments' do
      lambda { @host.configuration }.should_not raise_error(ArgumentError)
    end
    
    it 'should allow no arguments' do
      lambda { @host.configuration(:foo) }.should raise_error(ArgumentError)
    end
    
    describe 'and the host has no instances deployed' do
      it 'should return a hash of results' do
        @host.configuration.should respond_to(:keys)
      end
      
      it 'should include an empty class list in the results' do
        @host.configuration['classes'].should == []
      end
      
      it 'should include an empty hash of parameters in the results' do
        @host.configuration['parameters'].should == {}
      end
    end
    
    describe 'and the host has instances deployed' do
      before :each do
        @instances = Array.new(3) { Instance.generate! }
        @host.instances << @instances
      end
      
      it 'should include a class for each deployed instance in the returned class list' do
        @host.configuration['classes'].size.should == @instances.size
      end
      
      it 'should include no additional classes' do
        @host.configuration['classes'].size.should == @instances.size
      end
      
      it 'should use an unique class name for the deployed instance classes in the returned class list' do
        @host.configuration['classes'].sort.should == @instances.collect(&:configuration_name).sort
      end

      it "should include each instance's parameters, indexed by the unique class name for that instance" do
        result = @host.configuration
        @instances.each do |instance|
          result['parameters'][instance.configuration_name].should == instance.configuration_parameters
        end
      end
    end
  end
  
  it 'should be able to generate a Puppet manifest file' do
    Host.new.should respond_to(:puppet_manifest)
  end
  
  describe 'when generating a Puppet manifest file' do
    it 'should work without arguments' do
      lambda { Host.new.puppet_manifest }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { Host.new.puppet_manifest(:foo) }.should raise_error(ArgumentError)
    end
    
    describe 'and there are no instances deployed to this host' do
      it 'should return the empty string' do
        Host.generate!.puppet_manifest.should == ''
      end
    end
    
    describe 'and there are instances deployed to this host' do
      it 'should include the puppet manifest data for each instance' do
        @host = Host.generate!
        @host.instances << @instances = Array.new(3) { Instance.generate! }
        @instances.each do |instance| 
          @host.puppet_manifest.should match(Regexp.new(instance.puppet_manifest))
        end
      end      
    end
  end
    
  it 'should have a means to determine if it is safe to delete this host' do
    Host.new.should respond_to(:safe_to_delete?)
  end
  
  describe 'when determining if it is safe to delete this host' do
    before :each do
      @host = Host.generate!
    end
    
    it 'should work without arguments' do
      lambda { @host.safe_to_delete? }.should_not raise_error(ArgumentError)
    end
    
    it 'should not accept arguments' do
      lambda { @host.safe_to_delete?(:foo) }.should raise_error(ArgumentError)      
    end
    
    it 'should return false if the host has deployments' do
      @host.deployments.generate!
      @host.safe_to_delete?.should be_false
    end
    
    it 'should return true if the host has no deployements' do
      @host.safe_to_delete?.should be_true
    end
  end
  
  describe 'when deleting' do
    before :each do
      @host = Host.generate!
    end
    
    it 'should not allow deletion when it is not safe to delete' do
      @host.stubs(:safe_to_delete?).returns(false)
      lambda { @host.destroy }.should_not change(Host, :count)
    end
  
    it 'should allow deletion when it is safe to delete' do
      @host.stubs(:safe_to_delete?).returns(true)
      lambda { @host.destroy }.should change(Host, :count)    
    end
  end
end
