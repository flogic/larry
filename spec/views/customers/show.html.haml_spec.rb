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

  it 'should include a link to edit the customer' do
    do_render
    response.should have_tag('a[href=?]', edit_customer_path(@customer))    
  end
  
  it 'should include a link to delete the customer if it is safe to delete the customer' do
    @customer.stubs(:safe_to_delete?).returns(true)
    do_render
    response.should have_tag('a[href=?]', customer_path(@customer), :text => /[Dd]elete/)
  end
  
  it 'should not include a link to delete the customer if it is not safe to delete the customer' do
    @customer.stubs(:safe_to_delete?).returns(false)
    do_render
    response.should_not have_tag('a[href=?]', customer_path(@customer), :text => /[Dd]elete/)    
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
  
  it 'should include a link to add a new app' do
    do_render
    response.should have_tag('a[href=?]', new_customer_app_path(@customer))
  end
  
  it 'should list the apps the customer owns' do
    do_render
    @apps.each do |app|
      response.should have_text(Regexp.new(app.name))
    end
  end
  
  it 'should show a summary for each app' do
    @apps.each do |app|
      template.expects(:summarize).with(app)
    end
    do_render
  end
  
  describe 'parameters' do
    before :each do
      @customer.parameters = { 'field 1' => 'value 1', 'field 2' => 'value 2' }
    end
    
    it 'should show parameters for this customer' do
      do_render
      @customer.parameters.each_pair do |parameter, value|
        response.should have_text(/#{parameter}.*#{value}/)
      end
    end
  end
end
