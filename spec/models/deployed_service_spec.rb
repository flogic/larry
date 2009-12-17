require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe DeployedService do
  describe 'attributes' do
    before :each do
      @deployed_service = DeployedService.new
    end
    
    it 'should have a deployment id' do
      @deployed_service.should respond_to(:deployment)
    end
    
    it 'should allow setting and retrieving the deployment id' do
      @deployed_service.deployment_id = 1
      @deployed_service.deployment_id.should == 1
    end

    it 'should have a host id' do
      @deployed_service.should respond_to(:host_id)
    end
    
    it 'should allow setting and retrieving the host id' do
      @deployed_service.host_id = 1
      @deployed_service.host_id.should == 1
    end
    
    it 'should have a service name' do
      @deployed_service.should respond_to(:service_name)
    end
    
    it 'should allow setting and retrieving the service name' do
      @deployed_service.service_name = 'Larry'
      @deployed_service.service_name.should == 'Larry'      
    end
    
    it 'should have a set of parameters' do
      @deployed_service.should respond_to(:parameters)
    end
    
    it 'should allow setting and retrieving parameter values' do
      @deployed_service.parameters = { :foo => 'bar' }
      @deployed_service.parameters[:foo].should == 'bar'
    end
    
    it 'should preserve parameters as a hash across saving' do
      @deployed_service = DeployedService.generate!(:parameters => { :foo => 'bar'})
      DeployedService.find(@deployed_service.id).parameters[:foo].should == 'bar'
    end
    
    it 'should return an empty hash for parameters when parameters is empty' do
      @deployed_service.parameters = nil
      @deployed_service.parameters.should == {}
    end
  end
  
  describe 'validations' do
    before :each do
      @deployed_service = DeployedService.new
    end
    
    it 'should not be valid without a deployment' do
      @deployed_service.deployment = nil
      @deployed_service.valid?
      @deployed_service.errors.should be_invalid(:deployment)
    end

    it 'should be valid with a deployment' do
      @deployed_service.deployment = Deployment.generate!
      @deployed_service.valid?
      @deployed_service.errors.should_not be_invalid(:deployment)
    end

    it 'should not be valid without a host' do
      @deployed_service.host = nil
      @deployed_service.valid?
      @deployed_service.errors.should be_invalid(:host)
    end

    it 'should be valid with a host' do
      @deployed_service.host = Host.generate!
      @deployed_service.valid?
      @deployed_service.errors.should_not be_invalid(:host)
    end


    it 'should not be valid without a service name' do
      @deployed_service.service_name = nil
      @deployed_service.valid?
      @deployed_service.errors.should be_invalid(:service_name)
    end

    it 'should be valid with a service name' do
      @deployed_service.service_name = 'Larry'
      @deployed_service.valid?
      @deployed_service.errors.should_not be_invalid(:service_name)
    end
  end
  
  describe 'relationships' do
    before :each do
      @deployed_service = DeployedService.new
    end
    
    it 'should belong to a deployment' do
      @deployed_service.should respond_to(:deployment)      
    end
    
    it 'should allow assigning the deployment' do
      @deployment = Deployment.generate!
      @deployed_service.deployment = @deployment
      @deployed_service.deployment.should == @deployment
    end
    
    it 'should belong to a host' do
      @deployed_service.should respond_to(:host)
    end

    it 'should allow assigning the host' do
      @host = Host.generate!
      @deployed_service.host = @host
      @deployed_service.host.should == @host
    end
    
    it 'should have a deployable' do
      @deployed_service.should respond_to(:deployable)
    end

    it "should return the deployment's deployable" do
      @deployed_service.deployment = Deployment.generate!
      @deployed_service.deployable.should == @deployed_service.deployment.deployable
    end

    it 'should have an instance' do
      @deployed_service.should respond_to(:instance)
    end

    it "should return the deployment's instance" do
      @deployed_service.deployment = Deployment.generate!
      @deployed_service.instance.should == @deployed_service.deployment.instance
    end

    it 'should have an app' do
      @deployed_service.should respond_to(:app)
    end
    
    it "should return the deployment's app" do
      @deployed_service.deployment = Deployment.generate!
      @deployed_service.app.should == @deployed_service.deployment.app
    end
    
    it 'should have a customer' do
      @deployed_service.should respond_to(:customer)
    end
    
    it "should return the deployment's customer" do
      @deployed_service.deployment = Deployment.generate!
      @deployed_service.customer.should == @deployed_service.deployment.customer
    end
  end
end
