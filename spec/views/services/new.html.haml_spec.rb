require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/services/new' do
  before :each do
    assigns[:service] = @service = Service.new
  end

  def do_render
    render '/services/new'
  end

  it 'should include a service creation form' do
    do_render
    response.should have_tag('form[id=?]', 'new_service')
  end
  
  describe 'service creation form' do
    it 'should send its contents to the service create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_service', services_path)
    end
    
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_service', 'post')      
    end
    
    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', 'new_service') do
        with_tag('input[type=?][name=?]', 'text', 'service[name]')
      end
    end
    
    it 'should preserve any existing name' do
      @service.name = 'Test Name'
      do_render
      response.should have_tag('form[id=?]', 'new_service') do
        with_tag('input[type=?][name=?][value=?]', 'text', 'service[name]', 'Test Name')
      end      
    end
    
    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', 'new_service') do
        with_tag('textarea[name=?]', 'service[description]')
      end      
    end
    
    it 'should preserve any existing description' do
      @service.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', 'new_service') do
        with_tag('textarea[name=?]', 'service[description]', :text => /Test Description/)
      end            
    end
    
    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_service') do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
