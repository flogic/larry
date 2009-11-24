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
    end

    def do_request
      post :create, :app => @app.attributes
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
  end

  describe 'update' do
    def do_request
      put :update, :id => @app.id.to_s, :app => @app.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @app.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
end

describe AppsController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller'
end
