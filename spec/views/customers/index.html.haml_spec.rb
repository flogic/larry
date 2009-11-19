require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/customers/index' do
  before :each do
    assigns[:customers] = @customers = Array.new(3) { Customer.generate! }
  end

  def do_render
    render '/customers/index'
  end

  it 'should display the name of each customer' do
    do_render
    @customers.each do |customer|
      response.should have_text(Regexp.new(customer.name))
    end
  end
  
  it 'should link the customer name to the page for that customer' do
    do_render
    @customers.each do |customer|
      response.should have_tag('a[href=?]', customer_path(customer), :text => customer.name)
    end
  end
end
