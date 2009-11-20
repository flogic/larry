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
end
