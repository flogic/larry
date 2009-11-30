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
    
    it 'should have many deployed services' do
      @host.should respond_to(:deployed_services)
    end
        
    it 'should allow setting and retrieving deployed services' do
      deployed_services = Array.new(2) { DeployedService.generate!(:host => @host) }
      @host.deployed_services.sort_by(&:id).should == deployed_services.sort_by(&:id)
    end
    
    it 'should have many deployments' do
      @host.should respond_to(:deployments)
    end
   
    it "should return deployed services' deployments" do
      deployed_services = Array.new(2) { DeployedService.generate!(:host => @host) }
      @host.deployments.sort_by(&:id).should == deployed_services.collect(&:deployment).sort_by(&:id)
    end
            
    it "should not return deployments which are not active" do
      deployed_service = DeployedService.generate!(:host => @host)
      deployed_service.deployment.update_attribute(:start_time, 1.day.from_now)
      @host.deployments.should == []
    end

    it 'should have many deployables' do
      @host.should respond_to(:deployments)
    end
    
    it "should return deployed services' deployables" do
      deployed_services = Array.new(2) { DeployedService.generate!(:host => @host) }
      @host.deployables.sort_by(&:id).should == deployed_services.collect(&:deployable).sort_by(&:id)      
    end
    
    it "should not return deployed services' deployables for deployments which are not active" do
      deployed_service = DeployedService.generate!(:host => @host)
      deployed_service.deployment.update_attribute(:start_time, 1.day.from_now)
      @host.deployables.should == []
    end

    it 'should have many instances' do
      @host.should respond_to(:instances)
    end
    
    it "should return deployed services' instances" do
      deployed_services = Array.new(2) { DeployedService.generate!(:host => @host) }
      @host.instances.sort_by(&:id).should == deployed_services.collect(&:instance).sort_by(&:id)
    end

    it "should not return deployed services' instances for deployments which are not active" do
      deployed_service = DeployedService.generate!(:host => @host)
      deployed_service.deployment.update_attribute(:start_time, 1.day.from_now)
      @host.instances.should == []
    end

    it 'should have many apps' do
      @host.should respond_to(:apps)
    end
    
    it "should return deployed services' apps" do
      deployed_services = Array.new(2) { DeployedService.generate!(:host => @host) }
      @host.apps.sort_by(&:id).should == deployed_services.collect(&:app).sort_by(&:id)
    end
        
    it "should not return deployed services' apps for deployments which are not active" do
      deployed_service = DeployedService.generate!(:host => @host)
      deployed_service.deployment.update_attribute(:start_time, 1.day.from_now)
      @host.apps.should == []
    end

    it 'should have many customers' do
      @host.should respond_to(:customers)      
    end
    
    it "should return deployed services' customers" do
      deployed_services = Array.new(2) { DeployedService.generate!(:host => @host) }
      @host.customers.sort_by(&:id).should == deployed_services.collect(&:customer).sort_by(&:id)
    end
    
    it "should not return deployed services' customers for deployments which are not active" do
      deployed_service = DeployedService.generate!(:host => @host)
      deployed_service.deployment.update_attribute(:start_time, 1.day.from_now)
      @host.customers.should == []
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
    
    describe 'and the host has no deployed services' do
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
    
    describe 'and the host has deployed services' do
      before :each do
        @host.deployed_services << @deployed_services = Array.new(3) { DeployedService.generate! }
      end
      
      it 'should include a class for each instance in the returned class list' do
        @host.configuration['classes'].size.should == @host.instances.size
      end
      
      it 'should include no additional classes' do
        @host.configuration['classes'].size.should == @host.instances.size
      end
      
      it 'should use an unique class name for the deployed instance classes in the returned class list' do
        @host.configuration['classes'].sort.should == @host.instances.collect(&:configuration_name).sort
      end

      it "should include each instance's parameters, indexed by the unique class name for that instance" do
        result = @host.configuration
        @host.instances.each do |instance|
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
        @host.deployed_services << deployed_services = Array.new(3) { DeployedService.generate! }
        @host.instances.each do |instance| 
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
    
    it 'should return false if the host has deployed services' do
      DeployedService.generate!(:host => @host)
      @host.safe_to_delete?.should be_false
    end
    
    it 'should return false if the host has deployed services from past inactive deployments' do
      deployed_service = DeployedService.generate!(:host => @host)
      deployed_service.deployment.update_attribute(:start_time, 5.days.ago)
      deployed_service.deployment.update_attribute(:end_time, 4.days.ago)
      @host.safe_to_delete?.should be_false
    end
    
    it 'should return true if the host has never had any deployed services' do
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
