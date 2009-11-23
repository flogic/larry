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
          with_tag('a[href=?]', html_escape(link_edges_path(:source_id => @service, :target_id => service)))
        end
      end      
    end
  end
end
