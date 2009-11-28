require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DeploymentsController, 'when integrating' do
  integrate_views

  before :each do
    @deployment = Deployment.generate!
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
    
    describe 'when a instance scope is specified' do
      it 'should fail if the requested instance cannot be found' do
        lambda { get :new, :instance_id => (Instance.last.id + 10).to_s }.should raise_error
      end
      
      it 'should make the instance available to the view' do
        pending('unfucking the instance...deployments modeling') do
          instance = Instance.generate!
          get :new, :instance_id => instance.id.to_s
          assigns[:instance].should == instance
        end
      end
    end
  end

  describe 'show' do
    def do_request
      get :show, :id => @deployment.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @deployment.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    before :each do
      @deployment = Deployment.spawn
      @params = { :deployment => @deployment.attributes }
    end

    def do_request
      post :create, @params
    end

    it_should_behave_like "a redirecting action"
    
    describe 'when a instance scope is specified' do
      it 'should fail if the requested instance cannot be found' do
        lambda { post :create, :deployment => @deployment.attributes, :instance_id => (Instance.last.id + 10).to_s }.should raise_error
      end
      
      it 'should create a new deployment for the specified instance' do
        pending('unfucking the instance...deployment modeling') do
          instance = Instance.generate!
          post :create, :deployment => @deployment.attributes, :instance_id => instance.id.to_s
          instance.deployments.should include(assigns[:deployment])
        end
      end
    end
  end

  describe 'update' do
    before :each do
      @deployment = Deployment.generate!
      @params = { :id => @deployment.id.to_s, :deployment => @deployment.attributes }
    end
    
    def do_request
      put :update, @params
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @deployment.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
end

describe DeploymentsController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller'
end
