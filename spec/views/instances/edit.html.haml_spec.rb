require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/instances/edit' do
  before :each do
    assigns[:instance] = @instance = Instance.generate!
  end

  def do_render
    render '/instances/edit'
  end

  it 'should include a link to the original instance' do
    do_render
    response.should have_tag('a[href=?]', instance_path(@instance))
  end

  it 'should include a instance edit form' do
    do_render
    response.should have_tag('form[id=?]', "edit_instance_#{@instance.id}")
  end
  
  describe 'instance creation form' do
    it 'should send its contents to the instance create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', "edit_instance_#{@instance.id}", instance_path(@instance))
    end
    
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', "edit_instance_#{@instance.id}", 'post')      
    end
    
    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', "edit_instance_#{@instance.id}") do
        with_tag('input[type=?][name=?]', 'text', 'instance[name]')
      end
    end
    
    it 'should preserve any existing name' do
      @instance.name = 'Test Name'
      do_render
      response.should have_tag('form[id=?]', "edit_instance_#{@instance.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'instance[name]', 'Test Name')
      end      
    end
    
    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', "edit_instance_#{@instance.id}") do
        with_tag('textarea[name=?]', 'instance[description]')
      end      
    end
    
    it 'should preserve any existing description' do
      @instance.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', "edit_instance_#{@instance.id}") do
        with_tag('textarea[name=?]', 'instance[description]', :text => /Test Description/)
      end            
    end
    
    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', "edit_instance_#{@instance.id}") do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
