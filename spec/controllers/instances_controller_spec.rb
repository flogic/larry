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
end

describe InstancesController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller with an index action'
  it_should_behave_like 'a RESTful controller with a show action'
  it_should_behave_like 'a RESTful controller with a new action'
  it_should_behave_like 'a RESTful controller with an edit action'
  it_should_behave_like 'a RESTful controller with a destroy action'
end
