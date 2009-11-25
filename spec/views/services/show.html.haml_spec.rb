require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/services/show' do
  before :each do
    assigns[:service] = @service = Service.generate!(:description => 'Test Service')
  end

  def do_render
    render '/services/show'
  end

  it 'should display the name of the service' do
    do_render
    response.should have_text(Regexp.new(@service.name))
  end
  
  it 'should display the description of the service' do
    do_render
    response.should have_text(Regexp.new(@service.description))
  end
  
  it 'should include a link to edit the service' do
    do_render
    response.should have_tag('a[href=?]', edit_service_path(@service))    
  end
  
  it 'should include a link to delete the service if it is safe to delete the service' do
    @service.stubs(:safe_to_delete?).returns(true)
    do_render
    response.should have_tag('a[href=?]', service_path(@service), :text => /[Dd]elete/)
  end
  
  it 'should not include a link to delete the service if it is not safe to delete the service' do
    @service.stubs(:safe_to_delete?).returns(false)
    do_render
    response.should_not have_tag('a[href=?]', service_path(@service), :text => /[Dd]elete/)    
  end
  
  it 'should list the parameters this service needs' do
    @service.parameters = [ 'field 1', 'field 2', 'field 3' ]
    do_render
    @service.parameters.each do |parameter|
      response.should have_text(Regexp.new(parameter))
    end
  end
  
  it 'should list the parameters services we depend on need' do
    kid = Service.generate!(:parameters => ['kid field 1', 'kid field 2'])
    grandkid = Service.generate!(:parameters => ['grandkid field 1', 'grandkid field 2'])
    @service.depends_on << kid
    kid.depends_on << grandkid
    do_render
    (kid.parameters + grandkid.parameters).each do |parameter|
      response.should have_text(Regexp.new(parameter))
    end
  end

  it 'should show the services which depends on this service' do
    others = Array.new(3) { Service.generate! }
    @service.dependents << others
    do_render
    others.each do |other|
      response.should have_text(Regexp.new(other.name))
    end
  end
  
  it 'should show the services which this service depends on' do
    others = Array.new(3) { Service.generate! }
    @service.depends_on << others
    do_render
    others.each do |other|
      response.should have_text(Regexp.new(other.name))
    end
  end
  
  it 'should show the tree of services this service depends on' do
    kids = Array.new(3) { Service.generate! }
    grandkids = Array.new(3) { Service.generate! }
    kids.each {|k| k.depends_on << grandkids }
    @service.depends_on << kids
    do_render
    [kids, grandkids].flatten.each do |other|
      response.should have_text(Regexp.new(other.name))
    end    
  end
  
  it 'should provide a means to disconnect the services which this service directly depends on' do
    others = Array.new(3) { Service.generate! }
    @service.depends_on << others
    do_render
    others.each do |other|
      response.should have_tag('a[href=?]', edge_path(@service.edge_to(other)))
    end    
  end
    
  it 'should show the list of instances which require the service' do
    instances = Array.new(3) { Instance.generate! }
    @service.instances << instances
    do_render
    instances.each do |instance|
      response.should have_text(Regexp.new(instance.name))
    end
  end
  
  it 'should show the list of hosts on which the service is deployed' do
    instances = Array.new(5) { Instance.generate! }
    instances.each do |i| 
      i.services << @service
      Deployment.generate!(:instance => i)
    end
    do_render
    @service.hosts.each do |host|
      response.should have_text(Regexp.new(host.name))
    end
  end
  
  it 'should show the list of services which are not related to this service' do
    unrelated = Service.generate!
    do_render
    response.should have_tag('div[id=?]', 'unrelated_services')
  end
  
  describe 'list of unrelated services' do
    it 'should not contain services which depend on this service' do
      others = Array.new(3) { Service.generate! }
      @service.dependents << others
      do_render
      others.each do |other|
        response.should_not have_tag('div[id=?]', 'unrelated_services', :text => Regexp.new(other.name))
      end
    end
    
    it 'should not contain services which this service depends on' do
      others = Array.new(3) { Service.generate! }
      @service.depends_on << others
      do_render
      others.each do |other|
        response.should_not have_tag('div[id=?]', 'unrelated_services', :text => Regexp.new(other.name))
      end      
    end
    
    it 'should contain all the services which are unrelated to this service' do
      unrelated = Array.new(3) { Service.generate! }
      do_render
      unrelated.each do |service|
        response.should have_tag('div[id=?]', 'unrelated_services', :text => Regexp.new(service.name))
      end
    end
    
    it 'should provide a link to create a dependency on each unrelated service' do
      unrelated = Array.new(3) { Service.generate! }
      do_render
      unrelated.each do |service|
        response.should have_tag('div[id=?]', 'unrelated_services') do
          with_tag('a[href=?]', html_escape(edges_path(:edge => { :source_id => @service, :target_id => service })))
        end
      end      
    end
  end
end
