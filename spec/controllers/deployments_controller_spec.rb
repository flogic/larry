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
  it_should_behave_like 'a RESTful controller with an index action'
  it_should_behave_like 'a RESTful controller with an edit action'
  it_should_behave_like 'a RESTful controller with an update action'
  it_should_behave_like 'a RESTful controller with a show action'
  it_should_behave_like 'a RESTful controller with a destroy action'
end
