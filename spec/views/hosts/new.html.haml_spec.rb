require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/hosts/new' do
  before :each do
    assigns[:host] = @host = Host.new
  end

  def do_render
    render '/hosts/new'
  end

  it 'should include a host creation form' do
    do_render
    response.should have_tag('form[id=?]', 'new_host')
  end
  
  describe 'host creation form' do
    it 'should send its contents to the host create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_host', hosts_path)
    end
    
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_host', 'post')      
    end
    
    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', 'new_host') do
        with_tag('input[type=?][name=?]', 'text', 'host[name]')
      end
    end
    
    it 'should preserve any existing name' do
      @host.name = 'Test Name'
      do_render
      response.should have_tag('form[id=?]', 'new_host') do
        with_tag('input[type=?][name=?][value=?]', 'text', 'host[name]', 'Test Name')
      end      
    end
    
    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', 'new_host') do
        with_tag('textarea[name=?]', 'host[description]')
      end      
    end
    
    it 'should preserve any existing description' do
      @host.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', 'new_host') do
        with_tag('textarea[name=?]', 'host[description]', :text => /Test Description/)
      end            
    end
    
    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_host') do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
