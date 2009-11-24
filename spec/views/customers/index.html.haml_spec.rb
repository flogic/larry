require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/customers/index' do
  before :each do
    assigns[:customers] = @customers = Array.new(3) { Customer.generate! }
  end

  def do_render
    render '/customers/index'
  end

  it 'should show a summary for each customer' do
    @customers.each do |customer|
      template.expects(:summarize).with(customer)
    end
    do_render
  end
  
  it 'should include a link to add a new customer' do
    do_render
    response.should have_tag('a[href=?]', new_customer_path)
  end
  
  it 'should include a link to edit each customer' do
    do_render
    @customers.each do |customer|
      response.should have_tag('a[href=?]', edit_customer_path(customer))
    end
  end
  
  it 'should include a link to delete each customer if it is safe to delete the customer' do
    @customers.each { |customer| customer.stubs(:safe_to_delete?).returns(true) }
    do_render
    @customers.each do |customer|
      response.should have_tag('a[href=?]', customer_path(customer), :text => /[Dd]elete/)
    end
  end
  
  it 'should not include a link to delete each customer if it is not safe to delete the customer' do
    @customers.each { |customer| customer.stubs(:safe_to_delete?).returns(false) }
    do_render
    @customers.each do |customer|
      response.should_not have_tag('a[href=?]', customer_path(customer), :text => /[Dd]elete/)    
    end
  end
end
