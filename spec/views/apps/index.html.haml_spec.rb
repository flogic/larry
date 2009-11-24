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
  
  it 'should include a link to edit each app' do
    do_render
    @apps.each do |app|
      response.should have_tag('a[href=?]', edit_app_path(app))
    end
  end

  it 'should include a link to delete each app if it is safe to delete the app' do
    @apps.each { |app| app.stubs(:safe_to_delete?).returns(true) }
    do_render
    @apps.each do |app|
      response.should have_tag('a[href=?]', app_path(app), :text => /[Dd]elete/)
    end
  end
  
  it 'should not include a link to delete each app if it is not safe to delete the app' do
    @apps.each { |app| app.stubs(:safe_to_delete?).returns(false) }
    do_render
    @apps.each do |app|
      response.should_not have_tag('a[href=?]', app_path(app), :text => /[Dd]elete/)    
    end
  end
end
