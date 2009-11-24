require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/hosts/edit' do
  before :each do
    assigns[:host] = @host = Host.generate!
  end

  def do_render
    render '/hosts/edit'
  end

  it 'should include a link to the original host' do
    do_render
    response.should have_tag('a[href=?]', host_path(@host))
  end

  it 'should include a host edit form' do
    do_render
    response.should have_tag('form[id=?]', "edit_host_#{@host.id}")
  end
  
  describe 'host creation form' do
    it 'should send its contents to the host create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', "edit_host_#{@host.id}", host_path(@host))
    end
    
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', "edit_host_#{@host.id}", 'post')      
    end
    
    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', "edit_host_#{@host.id}") do
        with_tag('input[type=?][name=?]', 'text', 'host[name]')
      end
    end
    
    it 'should preserve any existing name' do
      @host.name = 'Test Name'
      do_render
      response.should have_tag('form[id=?]', "edit_host_#{@host.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'host[name]', 'Test Name')
      end      
    end
    
    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', "edit_host_#{@host.id}") do
        with_tag('textarea[name=?]', 'host[description]')
      end      
    end
    
    it 'should preserve any existing description' do
      @host.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', "edit_host_#{@host.id}") do
        with_tag('textarea[name=?]', 'host[description]', :text => /Test Description/)
      end            
    end
    
    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', "edit_host_#{@host.id}") do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
