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

  it 'should list the hosts the app has deployments on' do
    instance = Instance.generate!(:app => @app)
    deployments = Array.new(3) { Deployment.generate!(:instance => instance) }
    do_render
    @app.hosts.each do |host|
      response.should have_text(Regexp.new(host.name))
    end
  end
end
