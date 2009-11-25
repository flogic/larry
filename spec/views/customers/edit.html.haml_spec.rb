require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/customers/edit' do
  before :each do
    assigns[:customer] = @customer = Customer.generate!
  end

  def do_render
    render '/customers/edit'
  end

  it 'should include a link to the original customer' do
    do_render
    response.should have_tag('a[href=?]', customer_path(@customer))
  end

  it 'should include a customer edit form' do
    do_render
    response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}")
  end
  
  describe 'customer creation form' do
    it 'should send its contents to the customer create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', "edit_customer_#{@customer.id}", customer_path(@customer))
    end
    
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', "edit_customer_#{@customer.id}", 'post')      
    end
    
    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
        with_tag('input[type=?][name=?]', 'text', 'customer[name]')
      end
    end
    
    it 'should preserve any existing name' do
      @customer.name = 'Test Name'
      do_render
      response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'customer[name]', 'Test Name')
      end      
    end
    
    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
        with_tag('textarea[name=?]', 'customer[description]')
      end      
    end
    
    it 'should preserve any existing description' do
      @customer.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
        with_tag('textarea[name=?]', 'customer[description]', :text => /Test Description/)
      end            
    end
    
    describe 'when the customer has parameters' do
      before :each do
        @parameters = { 'a' => 'b', 'c' => 'd', 'e' => 'f' }
        @customer.parameters = @parameters
      end
      
      it 'should have an input for each parameter name' do
        do_render
        response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
          @parameters.each_pair do |key, value|
            with_tag('input[type=?][name=?][value=?]', 'text', 'customer[parameters][key][]', key)
          end
        end
      end
      
      it 'should have an input for each parameter value' do
        do_render
        response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
          @parameters.each_pair do |key, value|
            with_tag('input[type=?][name=?][value=?]', 'text', 'customer[parameters][value][]', value)
          end
        end
      end
      
      it 'should not have a blank input for parameter name' do
        do_render
        response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
          with_tag('input[type=?][name=?]:not(value)', 'text', 'customer[parameters][key][]')
        end
      end
      
      it 'should not have a blank input for parameter value' do
        do_render
        response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
          with_tag('input[type=?][name=?]:not(value)', 'text', 'customer[parameters][value][]')
        end
      end
      
      it 'should have a link to delete an existing parameter' do
        do_render
        response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
          with_tag('a[class=?]', 'delete_parameter_link', :count => @customer.parameters.size)
        end
      end
    end
    
    it 'should have a link to add a new parameter' do
      do_render
      response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
        with_tag('a[id=?]', 'add_parameter_link')
      end
    end
    
    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', "edit_customer_#{@customer.id}") do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
