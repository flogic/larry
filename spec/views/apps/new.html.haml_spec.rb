require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/apps/new' do
  before :each do
    assigns[:app] = @app = App.new
  end

  def do_render
    render '/apps/new'
  end

  it 'should include a app creation form' do
    do_render
    response.should have_tag('form[id=?]', 'new_app')
  end
  
  describe 'app creation form' do
    it 'should send its contents to the app create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_app', apps_path)
    end
    
    it 'should send its contents to the customer app create action when a customer is specified' do
      assigns[:customer] = customer = Customer.generate!
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_app', customer_apps_path(customer))
    end
    
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_app', 'post')      
    end
    
    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', 'new_app') do
        with_tag('input[type=?][name=?]', 'text', 'app[name]')
      end
    end
    
    it 'should preserve any existing name' do
      @app.name = 'Test Name'
      do_render
      response.should have_tag('form[id=?]', 'new_app') do
        with_tag('input[type=?][name=?][value=?]', 'text', 'app[name]', 'Test Name')
      end      
    end
    
    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', 'new_app') do
        with_tag('textarea[name=?]', 'app[description]')
      end      
    end
    
    it 'should preserve any existing description' do
      @app.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', 'new_app') do
        with_tag('textarea[name=?]', 'app[description]', :text => /Test Description/)
      end            
    end
    
    describe 'when the app has parameters' do
      before :each do
        @parameters = { 'a' => 'b', 'c' => 'd', 'e' => 'f' }
        @app.parameters = @parameters
      end
      
      it 'should have an input for each parameter name' do
        do_render
        response.should have_tag('form[id=?]', 'new_app') do
          @parameters.each_pair do |key, value|
            with_tag('input[type=?][name=?][value=?]', 'text', 'app[parameters][key][]', key)
          end
        end
      end
      
      it 'should have an input for each parameter value' do
        do_render
        response.should have_tag('form[id=?]', 'new_app') do
          @parameters.each_pair do |key, value|
            with_tag('input[type=?][name=?][value=?]', 'text', 'app[parameters][value][]', value)
          end
        end
      end
      
      it 'should not have a blank input for parameter name' do
        do_render
        response.should have_tag('form[id=?]', 'new_app') do
          with_tag('input[type=?][name=?]:not(value)', 'text', 'app[parameters][key][]')
        end
      end
      
      it 'should not have a blank input for parameter value' do
        do_render
        response.should have_tag('form[id=?]', 'new_app') do
          with_tag('input[type=?][name=?]:not(value)', 'text', 'app[parameters][value][]')
        end
      end
      
      it 'should have a link to delete an existing parameter' do
        do_render
        response.should have_tag('form[id=?]', 'new_app') do
          with_tag('a[class=?]', 'delete_parameter_link', :count => @app.parameters.size)
        end
      end
    end
    
    it 'should have a link to add a new parameter' do
      do_render
      response.should have_tag('form[id=?]', 'new_app') do
        with_tag('a[id=?]', 'add_parameter_link')
      end
    end
    
    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_app') do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
