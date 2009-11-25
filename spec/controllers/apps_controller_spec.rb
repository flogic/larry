require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AppsController, 'when integrating' do
  integrate_views

  before :each do
    @app = App.generate!
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
    
    describe 'when a customer scope is specified' do
      it 'should fail if the requested customer cannot be found' do
        lambda { get :new, :customer_id => (Customer.last.id + 10).to_s }.should raise_error
      end
      
      it 'should make the customer available to the view' do
        customer = Customer.generate!
        get :new, :customer_id => customer.id.to_s
        assigns[:customer].should == customer
      end
    end
  end

  describe 'show' do
    def do_request
      get :show, :id => @app.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @app.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    before :each do
      @app = App.spawn
      @params = { :app => @app.attributes }
    end

    def do_request
      post :create, @params
    end

    it_should_behave_like "a redirecting action"
    
    describe 'when a customer scope is specified' do
      it 'should fail if the requested customer cannot be found' do
        lambda { post :create, :app => @app.attributes, :customer_id => (Customer.last.id + 10).to_s }.should raise_error
      end
      
      it 'should create a new app for the specified customer' do
        customer = Customer.generate!
        post :create, :app => @app.attributes, :customer_id => customer.id.to_s
        customer.apps.should include(assigns[:app])
      end
    end
    
    describe 'when parameters are provided' do
      it 'should set the new app parameters to an empty hash when the data provides no empty parameters list' do
        @params[:app].delete('parameters')
        do_request
        App.find_by_name(@app.name).parameters.should == {}
      end
      
      it 'should set the new app parameters to an empty hash when the data provides an empty parameters list' do
        @params[:app]['parameters'] = {}
        do_request
        App.find_by_name(@app.name).parameters.should == {}
      end
      
      it 'should set the new app parameters to an empty hash when the data provides no non-blank parameter names' do
        @params[:app]['parameters'] = { 'key' => ['', '', ''], 'value' => ['1', '2', '3'] }
        do_request
        App.find_by_name(@app.name).parameters.should == {}          
      end
      
      it 'should set the new app parameters to a hash based on the data keys and values' do
        @params[:app]['parameters'] = { 'key' => ['a', '', 'c'], 'value' => ['b', 'x', 'd'] }
        do_request
        App.find_by_name(@app.name).parameters.should == { 'a' => 'b', 'c' => 'd' }                    
      end
    end
  end

  describe 'update' do
    before :each do
      @app = App.generate!
      @params = { :id => @app.id.to_s, :app => @app.attributes }
    end
    
    def do_request
      put :update, @params
    end

    it_should_behave_like "a redirecting action"
    
    describe 'when parameters are provided' do
      it 'should set the app parameters to an empty hash when the data provides no empty parameters list' do
        @params[:app].delete('parameters')
        do_request
        App.find(@app.id).parameters.should == {}
      end
      
      it 'should set the app parameters to an empty hash when the data provides an empty parameters list' do
        @params[:app]['parameters'] = {}
        do_request
        App.find(@app.id).parameters.should == {}
      end
      
      it 'should set the app parameters to an empty hash when the data provides no non-blank parameter names' do
        @params[:app]['parameters'] = { 'key' => ['', '', ''], 'value' => ['1', '2', '3'] }
        do_request
        App.find(@app.id).parameters.should == {}          
      end
      
      it 'should set the app parameters to a hash based on the data keys and values' do
        @params[:app]['parameters'] = { 'key' => ['a', '', 'c'], 'value' => ['b', 'x', 'd'] }
        do_request
        App.find(@app.id).parameters.should == { 'a' => 'b', 'c' => 'd' }                    
      end
    end
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @app.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
end

describe AppsController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller with an index action'
  it_should_behave_like 'a RESTful controller with a show action'
  it_should_behave_like 'a RESTful controller with a new action'
  it_should_behave_like 'a RESTful controller with an edit action'
  it_should_behave_like 'a RESTful controller with a destroy action'end
