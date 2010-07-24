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
      @host = Host.generate!
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
      it 'should return an empty list' do
        @host.configuration.should == []
      end
    end
    
    describe 'and the host has deployed services' do
      before :each do
        @deployed_services = Array.new(3) {|i| DeployedService.generate!(:host => @host, :parameters => { 'var' => "var #{i}", 'foo' => 'foo #{i}'}) }
        @instances = @deployed_services.collect(&:instance).uniq
      end

      # [ 
      #   { :customer => 'bob', :app => 'bob.com', :instance => 'db server', :services => [ { :name => 'mysqldb', :parameters => { 'dbname' => 'bobco_prod' } } ] }
      # ]
            
      it "should include an entry for each unique deployed instance from the host's deployed services" do
        @host.configuration.size.should == @instances.size
      end
      
      it 'should include the customer name in each instance record' do
        customers = @host.configuration.collect {|row| row[:customer] }
        @instances.each do |instance|
          customers.should include(instance.customer.name)
        end
      end
        
      it 'should include the app name in each instance record' do
        apps = @host.configuration.collect {|row| row[:app] }
        @instances.each do |instance|
          apps.should include(instance.app.name)
        end
      end
      
      it 'should include the instance name in each instance record' do
        instances = @host.configuration.collect {|row| row[:instance] }
        @instances.each do |instance|
          instances.should include(instance.name)
        end
      end
      
      it 'should include the list of services for each instance record' do
        @deployed_services.each do |deployed_service|
          row = @host.configuration.detect {|r| r[:instance] == deployed_service.instance.name }
          row[:services].collect {|s| s[:name] }.should include(deployed_service.service_name)
        end
      end
      
      it 'should include the parameter settings for each service in an instance record' do
        @deployed_services.each do |deployed_service|
          row = @host.configuration.detect {|r| r[:instance] == deployed_service.instance.name }
          service_hash = row[:services].detect {|s| s[:name] == deployed_service.service_name }
          service_hash[:parameters].should == deployed_service.parameters
        end        
      end
    end
  end
  
  it 'should be able to generate a puppet manifest file' do
    Host.new.should respond_to(:puppet_manifest)
  end
  
  describe 'when generating a puppet manifest file' do
    include NormalizeNames
    
    before :each do
      @host = Host.generate!
      @deployed_services = Array.new(3) do |i| 
        DeployedService.generate!(:host => @host, :parameters => { 'foo' => "bar #{i}", 'baz' => "xyzzy #{i}" })
      end
    end
    
    it 'should work without arguments' do
      lambda { @host.puppet_manifest }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @host.puppet_manifest(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should include a sanitized customer name in a class declaration for each deployed service' do
      manifest = @host.puppet_manifest
      @deployed_services.each do |deployed_service|
        manifest.should match(/class.*#{normalize_name(deployed_service.customer.name)}/)
      end
    end
    
    it 'should include a sanitized app name in a class declaration for each deployed service' do
      manifest = @host.puppet_manifest
      @deployed_services.each do |deployed_service|
        manifest.should match(/class.*#{normalize_name(deployed_service.app.name)}/)
      end
    end
    
    it 'should include a sanitized instance name in a class declaration for each deployed service' do
      manifest = @host.puppet_manifest
      @deployed_services.each do |deployed_service|
        manifest.should match(/class.*#{normalize_name(deployed_service.instance.name)}/)
      end
    end
    
    it 'should include a sanitized service name in a class declaration for each deployed service' do
      manifest = @host.puppet_manifest
      @deployed_services.each do |deployed_service|
        manifest.should match(/class.*#{normalize_name(deployed_service.service_name)}/)
      end
    end
    
    it 'should include parameter settings for every configuration parameter for each deployed service' do
      manifest = @host.puppet_manifest
      @deployed_services.each do |deployed_service|
        deployed_service.parameters.each_pair do |k,v|
          manifest.should match(/\$#{k}\s*=\s*"#{v}"/)
        end
      end      
    end
    
    it 'should include a class include directive for each deployed service' do
      manifest = @host.puppet_manifest
      @deployed_services.each do |deployed_service|
        manifest.should match(/include.*#{normalize_name(deployed_service.service_name)}/)
      end
    end
    
    it 'should include a class include directive for the host' do
      manifest = @host.puppet_manifest
      manifest.should match(/include #{normalize_name(@host.name)}/)      
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
  
  describe 'providing access to non-current data' do
    before :each do
      @host = Host.generate!
      
      @way_early = 5.days.ago
      @early = 1.day.ago
      @late = 1.day.from_now
      @way_late = 5.days.from_now

      @past = DeployedService.generate!(:host => @host)
      @past.deployment.update_attribute(:start_time, @way_early)
      @past.deployment.update_attribute(:end_time, @early)
      
      @current_open = DeployedService.generate!(:host => @host)
      @current_open.deployment.update_attribute(:start_time, @early)
      @current_open.deployment.update_attribute(:end_time, nil)
      
      @current_closed = DeployedService.generate!(:host => @host)
      @current_closed.deployment.update_attribute(:start_time, @early)
      @current_closed.deployment.update_attribute(:end_time, @late)
      
      @future = DeployedService.generate!(:host => @host)
      @future.deployment.update_attribute(:start_time, @late)
      @future.deployment.update_attribute(:end_time, @way_late)
      
      @all = [ @past, @current_closed, @current_open, @future ]
    end
    
    it 'should be able to find all deployed services for the host' do
      @host.all_deployed_services.sort_by(&:id).should == @all.sort_by(&:id)        
    end
    
    it 'should be able to find all deployments for the host' do
      @host.all_deployments.sort_by(&:id).should == @all.collect(&:deployment).sort_by(&:id)        
    end
    
    it 'should not return duplicate deployments' do
      new_open = DeployedService.generate!(:host => @host, :deployment => @current_open.deployment)
      new_open.deployment.update_attribute(:start_time, @early)
      new_open.deployment.update_attribute(:end_time, nil)
      @host.all_deployments.size.should == @all.size
    end
    
    it 'should be able to find all deployables for the host' do
      @host.all_deployables.sort_by(&:id).should == @all.collect(&:deployable).sort_by(&:id)        
    end
    
    it 'should be able to find all instances for the host' do
      @host.all_instances.sort_by(&:id).should == @all.collect(&:instance).sort_by(&:id)        
    end
    
    it 'should be able to find all apps for the host' do
      @host.all_apps.sort_by(&:id).should == @all.collect(&:app).sort_by(&:id)        
    end
    
    it 'should be able to find all customers for the host' do
      @host.all_customers.sort_by(&:id).should == @all.collect(&:customer).sort_by(&:id)        
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
