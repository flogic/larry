require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/instances/new_deployment' do
  before :each do
    assigns[:instance] = @instance = Instance.generate!
    assigns[:hosts] = @hosts = Array.new(3) { Host.generate! }
    assigns[:deployables] = @deployables = Array.new(3) { Deployable.generate!(:instance => @instance) }
  end

  def do_render
    render '/instances/new_deployment'
  end

  it 'should include a deployment creation form' do
    do_render
    response.should have_tag('form[id=?]', 'new_deployment')
  end
  
  describe 'instance creation form' do
    it 'should send its contents to the instance deploy action' do
      do_render
      response.should have_tag('form[id=?][action=?]', 'new_deployment', deploy_instance_path(@instance))
    end
      
    it 'should use the POST HTTP method' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_deployment', 'post')      
    end
    
    it 'should allow choosing from all the available hosts' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_deployment', 'post') do
        with_tag('select[name=?]', 'deployment[host_id]') do
          @hosts.each do |host|
            with_tag('option[value=?]', host.id.to_s, :text => Regexp.new(host.name))
          end
        end
      end     
    end
    
    it 'should allow choosing from all the available deployables for this instance' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_deployment', 'post') do
        with_tag('select[name=?]', 'deployable[deployable_id]') do
          @deployables.each do |deployable|
            with_tag('option[value=?]', deployable.id.to_s, :text => Regexp.new(deployable.last_deployment_time_string))
          end
        end
      end     
    end
    
    it 'should include an option to create a new deployable when deploying this instance' do
      do_render
      response.should have_tag('form[id=?][method=?]', 'new_deployment', 'post') do
        with_tag('select[name=?]', 'deployable[deployable_id]') do
          @deployables.each do |deployable|
            with_tag('option', :text => /[Nn]ew/)
          end
        end
      end      
    end
    
    it 'should have a reason input' do
      do_render
      response.should have_tag('form[id=?]', 'new_deployment') do
        with_tag('input[type=?][name=?]', 'text', 'deployment[reason]')
      end
    end
        
    it 'should have a start time' do
      do_render
      response.should have_tag('form[id=?]', 'new_deployment') do
        with_tag('input[type=?][name=?]', 'text', 'deployment[start_time]')
      end      
    end
    
    it 'should render the initial start time in the current local time zone' do
      Time.zone = ActiveSupport::TimeZone["Beijing"]
      do_render
      response.should have_tag('form[id=?]', 'new_deployment') do
        with_tag('input[type=?][name=?][value=?]', 'text', 'deployment[start_time]', Time.zone.now.to_s(:picker))
      end            
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_deployment') do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
