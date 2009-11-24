require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/services/index' do
  before :each do
    assigns[:services] = @services = Array.new(3) { Service.generate! }
  end

  def do_render
    render '/services/index'
  end

  it 'should show a summary for each service' do
    @services.each do |service|
      template.expects(:summarize).with(service)
    end
    do_render
  end
  
  it 'should include a link to delete each service if it is safe to delete the service' do
    @services.each { |service| service.stubs(:safe_to_delete?).returns(true) }
    do_render
    @services.each do |service|
      response.should have_tag('a[href=?]', service_path(service), :text => /[Dd]elete/)
    end
  end
  
  it 'should not include a link to delete each service if it is not safe to delete the service' do
    @services.each { |service| service.stubs(:safe_to_delete?).returns(false) }
    do_render
    @services.each do |service|
      response.should_not have_tag('a[href=?]', service_path(service), :text => /[Dd]elete/)    
    end
  end
end
