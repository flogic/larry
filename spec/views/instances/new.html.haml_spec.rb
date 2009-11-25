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
    
    it 'should send its contents to the app instance create action when a app is specified' do
      assigns[:app] = app = App.generate!
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_instance', app_instances_path(app))
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

    describe 'when the instance has no parameters' do
      before :each do
        @instance.parameters = []
      end
      
      it 'should have a blank input for parameter name' do
        do_render
        response.should have_tag('form[id=?]', 'new_instance') do
          with_tag('input[type=?][name=?]:not([value])', 'text', 'instance[parameters][key][]')
        end
      end

      it 'should have a blank input for parameter value' do
        do_render
        response.should have_tag('form[id=?]', 'new_instance') do
          with_tag('input[type=?][name=?]:not([value])', 'text', 'instance[parameters][value][]')
        end
      end
    end
    
    describe 'when the instance has nil parameters' do
      before :each do
        @instance.parameters = nil
      end
      
      it 'should have a blank input for parameter name' do
        do_render
        response.should have_tag('form[id=?]', 'new_instance') do
          with_tag('input[type=?][name=?]:not([value])', 'text', 'instance[parameters][key][]')
        end
      end

      it 'should have a blank input for parameter value' do
        do_render
        response.should have_tag('form[id=?]', 'new_instance') do
          with_tag('input[type=?][name=?]:not([value])', 'text', 'instance[parameters][value][]')
        end
      end
    end
    
    describe 'when the instance has parameters' do
      before :each do
        @parameters = { 'a' => 'b', 'c' => 'd', 'e' => 'f' }
        @instance.parameters = @parameters
      end
      
      it 'should have an input for each parameter name' do
        do_render
        response.should have_tag('form[id=?]', 'new_instance') do
          @parameters.each_pair do |key, value|
            with_tag('input[type=?][name=?][value=?]', 'text', 'instance[parameters][key][]', key)
          end
        end
      end
      
      it 'should have an input for each parameter value' do
        do_render
        response.should have_tag('form[id=?]', 'new_instance') do
          @parameters.each_pair do |key, value|
            with_tag('input[type=?][name=?][value=?]', 'text', 'instance[parameters][value][]', value)
          end
        end
      end
      
      it 'should not have a blank input for parameter name' do
        do_render
        response.should have_tag('form[id=?]', 'new_instance') do
          with_tag('input[type=?][name=?]:not(value)', 'text', 'instance[parameters][key][]')
        end
      end
      
      it 'should not have a blank input for parameter value' do
        do_render
        response.should have_tag('form[id=?]', 'new_instance') do
          with_tag('input[type=?][name=?]:not(value)', 'text', 'instance[parameters][value][]')
        end
      end
      
      it 'should have a link to delete an existing parameter' do
        do_render
        response.should have_tag('form[id=?]', 'new_instance') do
          with_tag('a[class=?]', 'delete_parameter_link', :count => @instance.parameters.size)
        end
      end
    end
    
    it 'should have a link to add a new parameter' do
      do_render
      response.should have_tag('form[id=?]', 'new_instance') do
        with_tag('a[id=?]', 'add_parameter_link')
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
