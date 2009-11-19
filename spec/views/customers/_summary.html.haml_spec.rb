require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/customers/summary' do
  before :each do
    @customer = Customer.generate!(:description => 'Test Customer')
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

  it 'should display the description of the customer' do
    do_render
    response.should have_text(Regexp.new(@customer.description))
  end

  it 'should display the names of the various customer apps' do
    apps = Array.new(3) { App.generate!(:customer => @customer) }
    do_render
    apps.each do |app|
      response.should have_text(Regexp.new(app.name))
    end
  end
end
