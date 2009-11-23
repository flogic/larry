require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/instances/show' do
  before :each do
    assigns[:instance] = @instance = Instance.generate!(:description => 'Test Instance')
  end

  def do_render
    render '/instances/show'
  end

  it 'should display the name of the instance' do
    do_render
    response.should have_text(Regexp.new(@instance.name))
  end
  
  it 'should display the description of the instance' do
    do_render
    response.should have_text(Regexp.new(@instance.description))
  end

  it 'should show any host on which the instance is deployed' do
    Deployment.generate!(:instance => @instance)
    do_render
    response.should have_text(Regexp.new(@instance.host.name))
  end
end
