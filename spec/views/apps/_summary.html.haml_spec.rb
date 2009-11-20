require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/apps/summary' do
  before :each do
    @app = App.generate!(:description => 'Test App')
  end

  def do_render
    render :partial => '/apps/summary', :locals => { :app => @app }
  end

  it 'should display the name of the app' do
    do_render
    response.should have_text(Regexp.new(@app.name))
  end
  
  it 'should link the app name to the app show page' do
    do_render
    response.should have_tag('a[href=?]', app_path(@app), :text => @app.name)
  end
  
  it 'should display the description of the app' do
    do_render
    response.should have_text(Regexp.new(@app.description))
  end
  
  it 'should include the name of the customer who owns the app' do
    do_render 
    response.should have_text(Regexp.new(@app.customer.name))
  end
  
  it 'should list any hosts to which the app is deployed' do
    instance = Instance.generate!(:app => @app)
    deployments = Array.new(3) { Deployment.generate!(:instance => instance) }
    do_render
    @app.hosts.each do |host|
      response.should have_text(Regexp.new(host.name))
    end
  end
end
