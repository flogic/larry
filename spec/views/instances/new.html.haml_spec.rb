require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/instances/new' do
  before :each do
    assigns[:instance] = @instance = Instance.new
  end

  def do_render
    render '/instances/new'
  end

  it 'should include a instance creation form' do
    do_render
    response.should have_tag('form[id=?]', 'new_instance')
  end
  
  describe 'instance creation form' do
    it 'should send its contents to the instance create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_instance', instances_path)
    end
    
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_instance', 'post')      
    end
    
    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', 'new_instance') do
        with_tag('input[type=?][name=?]', 'text', 'instance[name]')
      end
    end
    
    it 'should preserve any existing name' do
      @instance.name = 'Test Name'
      do_render
      response.should have_tag('form[id=?]', 'new_instance') do
        with_tag('input[type=?][name=?][value=?]', 'text', 'instance[name]', 'Test Name')
      end      
    end
    
    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', 'new_instance') do
        with_tag('textarea[name=?]', 'instance[description]')
      end      
    end
    
    it 'should preserve any existing description' do
      @instance.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', 'new_instance') do
        with_tag('textarea[name=?]', 'instance[description]', :text => /Test Description/)
      end            
    end
    
    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_instance') do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
