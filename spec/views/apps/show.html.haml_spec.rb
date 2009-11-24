require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/apps/show' do
  before :each do
    assigns[:app] = @app = App.generate!(:description => 'Test App')
  end

  def do_render
    render '/apps/show'
  end

  it 'should display the name of the app' do
    do_render
    response.should have_text(Regexp.new(@app.name))
  end
  
  it 'should display the description of the app' do
    do_render
    response.should have_text(Regexp.new(@app.description))
  end
  
  it 'should include a link to edit the app' do
    do_render
    response.should have_tag('a[href=?]', edit_app_path(@app))    
  end

  it 'should include a link to delete the app if it is safe to delete the app' do
    @app.stubs(:safe_to_delete?).returns(true)
    do_render
    response.should have_tag('a[href=?]', app_path(@app), :text => /[Dd]elete/)
  end
  
  it 'should not include a link to delete the app if it is not safe to delete the app' do
    @app.stubs(:safe_to_delete?).returns(false)
    do_render
    response.should_not have_tag('a[href=?]', app_path(@app), :text => /[Dd]elete/)    
  end

  it 'should display the customer who owns the app' do
    do_render
    response.should have_text(Regexp.new(@app.customer.name))
  end

  it 'should include a link to add a new instance' do
    do_render
    response.should have_tag('a[href=?]', new_app_instance_path(@app))
  end

  it 'should list the instances that belong to the app' do
    instances = Array.new(3) { Instance.generate!(:app => @app) }
    do_render
    instances.each do |instance|
      response.should have_text(Regexp.new(instance.name))
    end
  end

  it 'should list the hosts the app has deployments on' do
    instance = Instance.generate!(:app => @app)
    deployments = Array.new(3) { Deployment.generate!(:instance => instance) }
    do_render
    @app.hosts.each do |host|
      response.should have_text(Regexp.new(host.name))
    end
  end
end
