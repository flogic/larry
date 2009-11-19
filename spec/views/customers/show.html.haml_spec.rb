require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/customers/show' do
  before :each do
    assigns[:customer] = @customer = Customer.generate!
    @apps = Array.new(3) { App.generate!(:customer => @customer) }
  end

  def do_render
    render '/customers/show'
  end

  it 'should display the name of the customer' do
    do_render
    response.should have_text(Regexp.new(@customer.name))
  end
  
  it 'should list the apps the customer owns' do
    do_render
    @apps.each do |app|
      response.should have_text(Regexp.new(app.name))
    end
  end
  
  it 'should link each app to the app view page' do
    do_render
    @apps.each do |app|
      response.should have_tag('a[href=?]', app_path(app), :text => app.name)
    end    
  end
end
