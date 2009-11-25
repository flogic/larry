require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/apps/edit' do
  before :each do
    assigns[:app] = @app = App.generate!
  end

  def do_render
    render '/apps/edit'
  end

  it 'should include a link to the original app' do
    do_render
    response.should have_tag('a[href=?]', app_path(@app))
  end

  it 'should include a app edit form' do
    do_render
    response.should have_tag('form[id=?]', "edit_app_#{@app.id}")
  end
  
  describe 'app creation form' do
    it 'should send its contents to the app create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', "edit_app_#{@app.id}", app_path(@app))
    end
    
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', "edit_app_#{@app.id}", 'post')      
    end
    
    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
        with_tag('input[type=?][name=?]', 'text', 'app[name]')
      end
    end
    
    it 'should preserve any existing name' do
      @app.name = 'Test Name'
      do_render
      response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'app[name]', 'Test Name')
      end      
    end
    
    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
        with_tag('textarea[name=?]', 'app[description]')
      end      
    end
    
    it 'should preserve any existing description' do
      @app.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
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
        response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
          @parameters.each_pair do |key, value|
            with_tag('input[type=?][name=?][value=?]', 'text', 'app[parameters][key][]', key)
          end
        end
      end
      
      it 'should have an input for each parameter value' do
        do_render
        response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
          @parameters.each_pair do |key, value|
            with_tag('input[type=?][name=?][value=?]', 'text', 'app[parameters][value][]', value)
          end
        end
      end
      
      it 'should not have a blank input for parameter name' do
        do_render
        response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
          with_tag('input[type=?][name=?]:not(value)', 'text', 'app[parameters][key][]')
        end
      end
      
      it 'should not have a blank input for parameter value' do
        do_render
        response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
          with_tag('input[type=?][name=?]:not(value)', 'text', 'app[parameters][value][]')
        end
      end
      
      it 'should have a link to delete an existing parameter' do
        do_render
        response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
          with_tag('a[class=?]', 'delete_parameter_link', :count => @app.parameters.size)
        end
      end
    end
    
    it 'should have a link to add a new parameter' do
      do_render
      response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
        with_tag('a[id=?]', 'add_parameter_link')
      end
    end
    
    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', "edit_app_#{@app.id}") do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
