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
end
