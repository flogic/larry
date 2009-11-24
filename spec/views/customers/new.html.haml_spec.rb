require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/customers/new' do
  before :each do
    assigns[:customer] = @customer = Customer.new
  end

  def do_render
    render '/customers/new'
  end

  it 'should include a customer creation form' do
    do_render
    response.should have_tag('form[id=?]', 'new_customer')
  end
  
  describe 'customer creation form' do
    it 'should send its contents to the customer create action' do
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_customer', customers_path)
    end
    
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_customer', 'post')      
    end
    
    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', 'new_customer') do
        with_tag('input[type=?][name=?]', 'text', 'customer[name]')
      end
    end
    
    it 'should preserve any existing name' do
      @customer.name = 'Test Name'
      do_render
      response.should have_tag('form[id=?]', 'new_customer') do
        with_tag('input[type=?][name=?][value=?]', 'text', 'customer[name]', 'Test Name')
      end      
    end
    
    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', 'new_customer') do
        with_tag('textarea[name=?]', 'customer[description]')
      end      
    end
    
    it 'should preserve any existing description' do
      @customer.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', 'new_customer') do
        with_tag('textarea[name=?]', 'customer[description]', :text => /Test Description/)
      end            
    end
    
    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_customer') do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
