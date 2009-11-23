require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RequirementsController, 'when integrating' do
  integrate_views

  before :each do
    @requirement = Requirement.generate!
  end

  describe 'create' do
    def do_request
      post :create, :requirement => @requirement.attributes
    end

    it_should_behave_like "a redirecting action"
  end

  describe 'destroy' do
    before(:each) do
      @requirement = Requirement.generate!
      @requirement_id = @requirement.id.to_s
    end

    def do_delete
      delete :destroy, { :id => @requirement_id }
    end
    
    it 'should fail if requested requirement does not exist' do
      @requirement.destroy
      lambda { do_delete }.should raise_error
    end
    
    it 'should delete the requested requirement' do
      lambda { do_delete }.should change(Requirement, :count)
    end

    it 'should redirect to the source service after deleting an requirement' do
      instance = @requirement.instance
      delete :destroy, :id => @requirement_id
      response.should redirect_to(instance_path(instance))
    end
  end
end

describe RequirementsController, 'when not integrating' do 
  describe 'create' do
    before :each do
      @instance, @service = Instance.generate!, Service.generate!
      @instance_id, @service_id = @instance.id.to_s, @service.id.to_s
    end
    
    it 'should fail when no instance_id is provided' do
      lambda { post :create, :requirement => { :service_id => @service_id } }.should raise_error      
    end

    it 'should fail when no service_id is provided' do
      lambda { post :create, :requirement => { :instance_id => @instance_id } }.should raise_error
    end
    
    it 'should fail when an invalid instance_id is provided' do
      lambda { post :create, :requirement => { :instance_id => (@instance.id+100).to_s, :service_id => @service_id } }.should raise_error      
    end
    
    it 'should fail when an invalid service_id is provided' do
      lambda { post :create, :requirement => { :instance_id => @instance_id, :service_id => (@service.id+100).to_s } }.should raise_error            
    end
    
    it 'should create a new requirement from the instance to the service' do
      lambda { post :create, :requirement => { :instance_id => @instance_id, :service_id => @service_id } }.should change(Requirement, :count)
    end
    
    it 'should redirect to the instance show page' do
      post :create, :requirement => { :instance_id => @instance_id, :service_id => @service_id }
      response.should redirect_to(instance_path(@instance))
    end
  end
end
