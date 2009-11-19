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
  
  it 'should show a summary for each app' do
    @apps.each do |app|
      template.should_receive(:render).with(has_entry(:partial, 'apps/summary'), has_entry(:locals => { :app => app }))
    end
    do_render
  end
end
