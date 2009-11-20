require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/apps/index' do
  before :each do
    assigns[:apps] = @apps = Array.new(3) { App.generate! }
  end

  def do_render
    render '/apps/index'
  end

  it 'should show a summary for each app' do
    @apps.each do |app|
      template.expects(:summarize).with(app)
    end
    do_render
  end
end
