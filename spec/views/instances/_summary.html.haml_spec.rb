require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/instances/summary' do
  before :each do
    @instance = Instance.generate!(:description => 'Test Instance')
  end

  def do_render
    render :partial => '/instances/summary', :locals => { :instance => @instance }
  end

  it 'should display the name of the instance' do
    do_render
    response.should have_text(Regexp.new(@instance.name))
  end
  
  it 'should link the instance name to the instance show page' do
    do_render
    response.should have_tag('a[href=?]', instance_path(@instance), :text => @instance.name)
  end

  it 'should display the description of the instance' do
    do_render
    response.should have_text(Regexp.new(@instance.description))
  end
  
  it 'should show deployment hosts' do
    deployable = Deployable.generate!(:instance => @instance)
    deployment = Deployment.generate!(:deployable => deployable)
    deployed_service = DeployedService.generate!(:deployment => deployment)
    do_render
    response.should have_text(Regexp.new(deployed_service.host.name))
  end
end
