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

  it 'should include a link to edit the instance' do
    do_render
    response.should have_tag('a[href=?]', edit_instance_path(@instance))    
  end

  it 'should include a link to delete the instance if it is safe to delete the instance' do
    @instance.stubs(:safe_to_delete?).returns(true)
    do_render
    response.should have_tag('a[href=?]', instance_path(@instance), :text => /[Dd]elete/)
  end
  
  it 'should not include a link to delete the instance if it is not safe to delete the instance' do
    @instance.stubs(:safe_to_delete?).returns(false)
    do_render
    response.should_not have_tag('a[href=?]', instance_path(@instance), :text => /[Dd]elete/)    
  end

  it 'should display the app which this instance belongs to' do
    do_render
    response.should have_text(Regexp.new(@instance.app.name))
  end

  it 'should show any host on which the instance is deployed' do
    Deployment.generate!(:instance => @instance)
    do_render
    response.should have_text(Regexp.new(@instance.host.name))
  end
  
  describe 'service dependencies' do
    it 'should show the services which this instance requires' do
      services = Array.new(3) { Service.generate! }
      @instance.services << services
      do_render
      services.each do |service|
        response.should have_text(Regexp.new(service.name))
      end
    end

    it 'should show the full tree of services this instance depends on' do
      kids = Array.new(3) { Service.generate! }
      grandkids = Array.new(3) { Service.generate! }
      kids.each {|k| k.depends_on << grandkids }
      @instance.services << kids
      do_render
      [kids, grandkids].flatten.each do |service|
        response.should have_text(Regexp.new(service.name))
      end    
    end

    it 'should provide a means to disconnect the services which this instance directly depends on' do
      services = Array.new(3) { Service.generate! }
      @instance.services << services
      do_render
      services.each do |service|
        response.should have_tag('a[href=?]', requirement_path(@instance.requirement_for(service)))
      end    
    end

    it 'should show the list of services which are not related to this instance' do
      unrelated = Service.generate!
      do_render
      response.should have_tag('div[id=?]', 'unrelated_services')
    end

    describe 'list of unrelated services' do
      it 'should not contain services which this instance depends on' do
        services = Array.new(3) { Service.generate! }
        @instance.services << services
        do_render
        services.each do |service|
          response.should_not have_tag('div[id=?]', 'unrelated_services', :text => Regexp.new(service.name))
        end      
      end

      it 'should contain all the services which are unrelated to this instance' do
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
            with_tag('a[href=?]', html_escape(requirements_path(:requirement => { :instance_id => @instance.id, :service_id => service.id })))
          end
        end
      end
    end
  end
end
