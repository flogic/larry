require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/hosts/show' do
  before :each do
    assigns[:host] = @host = Host.generate!(:description => 'Test Host')
  end

  def do_render
    render '/hosts/show'
  end

  it 'should display the name of the host' do
    do_render
    response.should have_text(Regexp.new(@host.name))
  end
  
  it 'should display the description of the host' do
    do_render
    response.should have_text(Regexp.new(@host.description))
  end

  it 'should list the apps the host has deployed' do
    deployments = Array.new(3) { Deployment.generate!(:host => @host) }
    do_render
    @host.apps.each do |app|
      response.should have_text(Regexp.new(app.name))
    end
  end
end
