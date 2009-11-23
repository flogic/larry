require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EdgesController, 'when integrating' do
  integrate_views

  before :each do
    @edge = Edge.generate!
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
      get :show, :id => @edge.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @edge.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    before :each do
      @edge = Edge.spawn
    end
    
    def do_request
      post :create, :edge => @edge.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'update' do
    def do_request
      put :update, :id => @edge.id.to_s, :edge => @edge.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @edge.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
  
  describe 'link' do
    before :each do
      @source, @target = Service.generate!, Service.generate!
      @source_id, @target_id = @source.id.to_s, @target.id.to_s
    end
    
    it 'should fail when no source_id is provided' do
      lambda { post :link, :target_id => @target_id }.should raise_error      
    end

    it 'should fail when no target_id is provided' do
      lambda { post :link, :source_id => @source_id }.should raise_error
    end
    
    it 'should fail when an invalid source_id is provided' do
      lambda { post :link, :source_id => (@source.id+100).to_s, :target_id => @target_id }.should raise_error      
    end
    
    it 'should fail when an invalid target_id is provided' do
      lambda { post :link, :source_id => @source_id, :target_id => (@target.id+100).to_s }.should raise_error            
    end
    
    it 'should create a new edge from the source to the target' do
      lambda { post :link, :source_id => @source_id, :target_id => @target_id }.should change(Edge, :count)
    end
    
    it 'should redirect to the source show page' do
      post :link, :source_id => @source_id, :target_id => @target_id
      response.should redirect_to(service_path(@source))
    end
  end
end

describe EdgesController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller'
end
