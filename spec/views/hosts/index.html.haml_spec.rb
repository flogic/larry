require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/hosts/index' do
  before :each do
    assigns[:hosts] = @hosts = Array.new(3) { Host.generate! }
  end

  def do_render
    render '/hosts/index'
  end

  it 'should show a summary for each host' do
    @hosts.each do |host|
      template.expects(:summarize).with(host)
    end
    do_render
  end
  
  it 'should include a link to add a new host' do
    do_render
    response.should have_tag('a[href=?]', new_host_path)
  end
  
  it 'should include a link to edit each host' do
    do_render
    @hosts.each do |host|
      response.should have_tag('a[href=?]', edit_host_path(host))
    end
  end
  
  it 'should include a link to delete each host if it is safe to delete the host' do
    @hosts.each { |host| host.stubs(:safe_to_delete?).returns(true) }
    do_render
    @hosts.each do |host|
      response.should have_tag('a[href=?]', host_path(host), :text => /[Dd]elete/)
    end
  end
  
  it 'should not include a link to delete each host if it is not safe to delete the host' do
    @hosts.each { |host| host.stubs(:safe_to_delete?).returns(false) }
    do_render
    @hosts.each do |host|
      response.should_not have_tag('a[href=?]', host_path(host), :text => /[Dd]elete/)    
    end
  end
end
