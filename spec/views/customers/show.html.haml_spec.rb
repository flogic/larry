require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/customers/show' do
  before :each do
    assigns[:customer] = @customer = Customer.generate!(:description => 'Test Customer')
    @apps = Array.new(3) { App.generate!(:customer => @customer) }
  end

  def do_render
    render '/customers/show'
  end

  it 'should display the name of the customer' do
    do_render
    response.should have_text(Regexp.new(@customer.name))
  end
  
  it 'should display the description of the customer' do
    do_render
    response.should have_text(Regexp.new(@customer.description))
  end

  it 'should list the hosts the customer has deployments on' do
    app = @apps.first
    instance = Instance.generate!(:app => app)
    deployments = Array.new(3) { Deployment.generate!(:instance => instance) }
    do_render
    @customer.hosts.each do |host|
      response.should have_text(Regexp.new(host.name))
    end
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
