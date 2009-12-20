require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InstancesController, 'when integrating' do
  integrate_views

  before :each do
    @instance = Instance.generate!
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
    
    describe 'when a app scope is specified' do
      it 'should fail if the requested app cannot be found' do
        lambda { get :new, :app_id => (App.last.id + 10).to_s }.should raise_error
      end
      
      it 'should make the app available to the view' do
        app = App.generate!
        get :new, :app_id => app.id.to_s
        assigns[:app].should == app
      end
    end
  end

  describe 'show' do
    def do_request
      get :show, :id => @instance.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @instance.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    before :each do
      @instance = Instance.spawn
      @params = { :instance => @instance.attributes }
    end

    def do_request
      post :create, @params
    end

    it_should_behave_like "a redirecting action"
    
    describe 'when a app scope is specified' do
      it 'should fail if the requested app cannot be found' do
        lambda { post :create, :instance => @params, :app_id => (App.last.id + 10).to_s }.should raise_error
      end
      
      it 'should create a new instance for the specified app' do
        app = App.generate!
        post :create, @params.merge(:app_id => app.id.to_s)
        app.instances.should include(assigns[:instance])
      end
    end
    
    describe 'when parameters are provided' do
      it 'should set the new instance parameters to an empty hash when the data provides no empty parameters list' do
        @params[:instance].delete('parameters')
        do_request
        Instance.find_by_name(@instance.name).parameters.should == {}
      end
      
      it 'should set the new instance parameters to an empty hash when the data provides an empty parameters list' do
        @params[:instance]['parameters'] = {}
        do_request
        Instance.find_by_name(@instance.name).parameters.should == {}
      end
      
      it 'should set the new instance parameters to an empty hash when the data provides no non-blank parameter names' do
        @params[:instance]['parameters'] = { 'key' => ['', '', ''], 'value' => ['1', '2', '3'] }
        do_request
        Instance.find_by_name(@instance.name).parameters.should == {}          
      end
      
      it 'should set the new instance parameters to a hash based on the data keys and values' do
        @params[:instance]['parameters'] = { 'key' => ['a', '', 'c'], 'value' => ['b', 'x', 'd'] }
        do_request
        Instance.find_by_name(@instance.name).parameters.should == { 'a' => 'b', 'c' => 'd' }                    
      end
      
      it 'should omit any parameter settings which have blank values' do
        @params[:instance]['parameters'] = { 'key' => ['a', 'j', 'c'], 'value' => ['b', '', 'd'] }
        do_request
        Instance.find_by_name(@instance.name).parameters.should == { 'a' => 'b', 'c' => 'd' }        
      end
    end
  end

  describe 'update' do
    before :each do
      @instance = Instance.generate!
      @params = { :id => @instance.id.to_s, :instance => @instance.attributes }
    end
    
    def do_request
      put :update, @params
    end

    it_should_behave_like "a redirecting action"
    
    describe 'when parameters are provided' do
      it 'should set the instance parameters to an empty hash when the data provides no empty parameters list' do
        @params[:instance].delete('parameters')
        do_request
        Instance.find(@instance.id).parameters.should == {}
      end
      
      it 'should set the instance parameters to an empty hash when the data provides an empty parameters list' do
        @params[:instance]['parameters'] = {}
        do_request
        Instance.find(@instance.id).parameters.should == {}
      end
      
      it 'should set the instance parameters to an empty hash when the data provides no non-blank parameter names' do
        @params[:instance]['parameters'] = { 'key' => ['', '', ''], 'value' => ['1', '2', '3'] }
        do_request
        Instance.find(@instance.id).parameters.should == {}          
      end
      
      it 'should set the instance parameters to a hash based on the data keys and values' do
        @params[:instance]['parameters'] = { 'key' => ['a', '', 'c'], 'value' => ['b', 'x', 'd'] }
        do_request
        Instance.find(@instance.id).parameters.should == { 'a' => 'b', 'c' => 'd' }                    
      end
      
      it 'should set the instance parameters to a hash based on the data keys and values' do
        @params[:instance]['parameters'] = { 'key' => ['a', 'j', 'c'], 'value' => ['b', '', 'd'] }
        do_request
        Instance.find(@instance.id).parameters.should == { 'a' => 'b', 'c' => 'd' }                    
      end      
    end
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @instance.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
  
  describe 'new_deployment' do
    def do_request
      get :new_deployment, :id => @instance.id.to_s
    end

    it 'should be successful' do
      do_request
      response.should be_success
    end
    
    it 'should not use a layout' do
      do_request
      response.layout.should be_nil
    end
    
    it 'should make the instance available to the view' do
      do_request
      assigns[:instance].id.should == @instance.id
    end
    
    it 'should make a list of hosts available to the view' do
      Array.new(2) { Host.generate! }
      do_request
      assigns[:hosts].sort_by(&:id).should == Host.all.sort_by(&:id)
    end
    
    it 'should make the list of current deployables for the instance available to the view' do
      deployables = Array.new(2) { Deployable.generate!(:instance => @instance) }
      do_request
      assigns[:deployables].should == deployables
    end
    
    it 'should render the new deployment view' do
      do_request
      response.should render_template('new_deployment')
    end
  end
  
  describe 'deploy' do
    before :each do 
      @instance = Instance.generate!
      @deployable = Deployable.generate!(:instance => @instance)
      @host = Host.generate!
      @parameters = { :start_time => Time.now, :reason => 'Because.', :host_id => @host.id }
    end
    
    def do_request(params = {})
      post :deploy, {:id => @instance.id.to_s, :deployment => @parameters, :deployable => @deployable }.merge(params)
    end
    
    describe 'when the instance is undeployable' do      
      it 'should set a flash message indicating the instance cannot be deployed' do
        do_request
        flash[:error].should match(/[Cc]annot/)
      end

      it 'should redirect to the instance show page' do
        do_request
        response.should redirect_to(instance_path(@instance))
      end
    end
    
    describe 'when the instance can be deployed' do
      before :each do
        @instance.services << @services = Array.new(2) { Service.generate! }
      end
      
      it 'should attempt to deploy the instance' do
        do_request
        @instance.deployments.size.should == 1
      end
      
      it 'should set a flash message indicating success' do
        do_request
        flash[:notice].should match(/uccess/)
      end
      
      it 'should set a flash message indicating failure when deployment fails' do
        do_request(:deployment => {})
        flash[:error].should match(/[Ff]ail|[Ee]rror/)
      end

      it 'should redirect to the instance show page' do
        do_request
        response.should redirect_to(instance_path(@instance))
      end
    end
  end
end

describe InstancesController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller with an index action'
  it_should_behave_like 'a RESTful controller with a show action'
  it_should_behave_like 'a RESTful controller with a new action'
  it_should_behave_like 'a RESTful controller with an edit action'
  it_should_behave_like 'a RESTful controller with a destroy action'
end
