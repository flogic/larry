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
  
  it 'should include a link to edit each instance' do
    do_render
    @instances.each do |instance|
      response.should have_tag('a[href=?]', edit_instance_path(instance))
    end
  end

  it 'should include a link to delete each instance if it is safe to delete the instance' do
    @instances.each { |instance| instance.stubs(:safe_to_delete?).returns(true) }
    do_render
    @instances.each do |instance|
      response.should have_tag('a[href=?]', instance_path(instance), :text => /[Dd]elete/)
    end
  end
  
  it 'should not include a link to delete each instance if it is not safe to delete the instance' do
    @instances.each { |instance| instance.stubs(:safe_to_delete?).returns(false) }
    do_render
    @instances.each do |instance|
      response.should_not have_tag('a[href=?]', instance_path(instance), :text => /[Dd]elete/)    
    end
  end
end
