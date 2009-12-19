require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HostsController, 'when integrating' do
  integrate_views

  before :each do
    @host = Host.generate!
  end

  describe 'index' do
    def do_request
      get :index
    end

    it_should_behave_like "a successful action"
  end

  describe 'new' do
    def do_request
      get :new
    end

    it_should_behave_like "a successful action"
  end

  describe 'show' do
    def do_request
      get :show, :id => @host.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @host.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    before :each do
      @host = Host.spawn
    end

    def do_request
      post :create, :host => @host.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'update' do
    def do_request
      put :update, :id => @host.id.to_s, :host => @host.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @host.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
  
  describe 'configuration' do
    before :each do
      @host = Host.generate!
      Array.new(3) { DeployedService.generate!(:host => @host)}
    end
    
    def do_request
      get :configuration, :name => @host.name
    end
    
    it_should_behave_like 'a redirecting action'
    
    it 'should fail when an unknown host name is provided' do
      lambda { get :configuration, :name => 'unknownhost' }.should raise_error
    end
    
    it "should return the host's puppet manifest if the format is .pp" do
      get :configuration, :name => @host.name, :format => 'pp'
      response.body.should == @host.puppet_manifest      
    end
    
    it "should return a JSON rendering of the host's configuration if the format is .json" do
      get :configuration, :name => @host.name, :format => 'json'
      response.body.should == @host.configuration.to_json
    end
    
    it "should return a YAML rendering of the host's configuration if the format is .yaml" do
      get :configuration, :name => @host.name, :format => 'yaml'
      response.body.should == @host.configuration.to_yaml
    end    
  end
end

describe HostsController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller'
end
