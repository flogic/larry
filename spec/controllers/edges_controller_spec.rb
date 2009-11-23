require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EdgesController, 'when integrating' do
  integrate_views

  before :each do
    @edge = Edge.generate!
  end

  describe 'create' do
    before :each do
      @source, @target = Service.generate!, Service.generate!
      @source_id, @target_id = @source.id.to_s, @target.id.to_s
    end
    
    it 'should fail when no source_id is provided' do
      lambda { post :create, :edge => { :target_id => @target_id } }.should raise_error      
    end

    it 'should fail when no target_id is provided' do
      lambda { post :create, :edge => { :source_id => @source_id } }.should raise_error
    end
    
    it 'should fail when an invalid source_id is provided' do
      lambda { post :create, :edge => { :source_id => (@source.id+100).to_s, :target_id => @target_id } }.should raise_error      
    end
    
    it 'should fail when an invalid target_id is provided' do
      lambda { post :create, :edge => { :source_id => @source_id, :target_id => (@target.id+100).to_s } }.should raise_error            
    end
    
    it 'should create a new edge from the source to the target' do
      lambda { post :create, :edge => { :source_id => @source_id, :target_id => @target_id } }.should change(Edge, :count)
    end
    
    it 'should redirect to the source show page' do
      post :create, :edge => { :source_id => @source_id, :target_id => @target_id }
      response.should redirect_to(service_path(@source))
    end
  end
  
  describe 'destroy' do
    before(:each) do
      @edge = Edge.generate!
      @edge_id = @edge.id.to_s
    end

    def do_delete
      delete :destroy, { :id => @edge_id }
    end
    
    it 'should fail if requested edge does not exist' do
      @edge.destroy
      lambda { do_delete }.should raise_error
    end
    
    it 'should delete the requested edge' do
      lambda { do_delete }.should change(Edge, :count)
    end

    it 'should redirect to the source service after deleting an edge' do
      source = @edge.source
      delete :destroy, :id => @edge_id
      response.should redirect_to(service_path(source))
    end
  end
end
