require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/services/summary' do
  before :each do
    @service = Service.generate!(:description => 'Test Service')
  end

  def do_render
    render :partial => '/services/summary', :locals => { :service => @service }
  end

  it 'should display the name of the service' do
    do_render
    response.should have_text(Regexp.new(@service.name))
  end
  
  it 'should link the service name to the service show page' do
    do_render
    response.should have_tag('a[href=?]', service_path(@service), :text => @service.name)
  end

  it 'should display the description of the service' do
    do_render
    response.should have_text(Regexp.new(@service.description))
  end

  it 'should display the services this service depends on' do
    others = Array.new(3) { Service.generate! }
    @service.depends_on << others
    do_render
    others.each do |other|
      response.should have_text(Regexp.new(other.name))
    end
  end

  it 'should display a count of how many services depend on this service' do
    others = Array.new(3) { Service.generate! }
    @service.dependents << others
    do_render
    response.should have_text(/\s+#{others.size}\b/)
  end
  
  it 'should show a count of the apps using this service' do
    instances = Array.new(4) { Instance.generate! }
    instances.each do |i| 
      i.services << @service
    end
    do_render
    response.should have_text(/\s+#{@service.apps.size}\b/)    
  end
  
  it 'should show a list of the hosts which have this service deployed' do
    @service.deployed_services << Array.new(2) { DeployedService.generate! }
    do_render
    @service.hosts.each do |host|
      response.should have_text(Regexp.new(host.name))
    end
  end
end
