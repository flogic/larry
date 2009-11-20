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
end
