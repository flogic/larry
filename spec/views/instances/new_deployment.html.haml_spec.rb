require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/instances/new_deployment' do
  before :each do
    assigns[:instance] = @instance = Instance.generate!
    assigns[:hosts] = @hosts = Array.new(3) { Host.generate! }
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

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_deployment') do
        with_tag('input[type=?]', 'submit')
      end      
    end
  end
end
