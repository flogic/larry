require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/services/edit' do
  before :each do
    assigns[:service] = @service = Service.generate!
  end

  def do_render
    render '/services/edit'
  end

  it 'should include a link to the original service' do
    do_render
    response.should have_tag('a[href=?]', service_path(@service))
  end

  it 'should include a service edit form' do
    do_render
    response.should have_tag('form[id=?]', "edit_service_#{@service.id}")
  end
  
  describe 'service creation form' do
    it 'should send its contents to the service create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', "edit_service_#{@service.id}", service_path(@service))
    end
    
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', "edit_service_#{@service.id}", 'post')      
    end
    
    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', "edit_service_#{@service.id}") do
        with_tag('input[type=?][name=?]', 'text', 'service[name]')
      end
    end
    
    it 'should preserve any existing name' do
      @service.name = 'Test Name'
      do_render
      response.should have_tag('form[id=?]', "edit_service_#{@service.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'service[name]', 'Test Name')
      end      
    end
    
    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', "edit_service_#{@service.id}") do
        with_tag('textarea[name=?]', 'service[description]')
      end      
    end
    
    it 'should preserve any existing description' do
      @service.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', "edit_service_#{@service.id}") do
        with_tag('textarea[name=?]', 'service[description]', :text => /Test Description/)
      end            
    end
    
    it 'should have an input for each existing parameter' do
      @service.parameters = ['field 1', 'field 2']
      do_render
      response.should have_tag('form[id=?]', "edit_service_#{@service.id}") do
        @service.parameters.each do |parameter|
          with_tag('input[type=?][name=?][value=?]', 'text', 'service[parameters][]', parameter)
        end
      end      
    end
    
    it 'should have a link to delete each existing parameter' do
      @service.parameters = ['field 1', 'field 2']
      do_render
      response.should have_tag('form[id=?]', "edit_service_#{@service.id}") do
        with_tag('a[class=?]', 'delete_parameter_link', :count => @service.parameters.size)
      end
    end
    
    it 'should have a link to add a new parameter' do
      do_render
      response.should have_tag('form[id=?]', "edit_service_#{@service.id}") do
        with_tag('a[id=?]', 'add_parameter_link')
      end
    end
    
    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', "edit_service_#{@service.id}") do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
