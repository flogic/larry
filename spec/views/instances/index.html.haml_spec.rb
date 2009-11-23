require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/instances/index' do
  before :each do
    assigns[:instances] = @instances = Array.new(3) { Instance.generate! }
  end

  def do_render
    render '/instances/index'
  end

  it 'should show a summary for each instance' do
    @instances.each do |instance|
      template.expects(:summarize).with(instance)
    end
    do_render
  end
end
