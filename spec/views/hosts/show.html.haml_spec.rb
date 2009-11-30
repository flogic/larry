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
  
  it 'should include a link to edit the host' do
    do_render
    response.should have_tag('a[href=?]', edit_host_path(@host))    
  end

  it 'should include a link to delete the host if it is safe to delete the host' do
    @host.stubs(:safe_to_delete?).returns(true)
    do_render
    response.should have_tag('a[href=?]', host_path(@host), :text => /[Dd]elete/)
  end
  
  it 'should not include a link to delete the host if it is not safe to delete the host' do
    @host.stubs(:safe_to_delete?).returns(false)
    do_render
    response.should_not have_tag('a[href=?]', host_path(@host), :text => /[Dd]elete/)    
  end
  
  it 'should list the apps the host has deployed' do
    deployed_services = Array.new(3) { DeployedService.generate!(:host => @host) }
    do_render
    @host.apps.each do |app|
      response.should have_text(Regexp.new(app.name))
    end
  end
end
