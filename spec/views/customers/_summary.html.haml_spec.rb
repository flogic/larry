require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/customers/summary' do
  before :each do
    @customer = Customer.generate!
  end

  def do_render
    render :partial => '/customers/summary', :locals => { :customer => @customer }
  end

  it 'should display the name of the customer' do
    do_render
    response.should have_text(Regexp.new(@customer.name))
  end
  
  it 'should link the customer name to the customer show page' do
    do_render
    response.should have_tag('a[href=?]', customer_path(@customer), :text => @customer.name)
  end
end
