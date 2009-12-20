require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe InstancesHelper do
  it 'should format options for deployable selection' do
    helper.should respond_to(:options_for_deployables)
  end
  
  describe 'formatting options for deployable selection' do
    before :each do
      @deployables = Array.new(3) { Deployment.generate! }.collect(&:deployable)
    end
    
    it 'should accept a list of deployables' do
      lambda { helper.options_for_deployables([])}.should_not raise_error(ArgumentError)
    end
    
    it 'should require a list of deployables' do
      lambda { helper.options_for_deployables }.should raise_error(ArgumentError)
    end
    
    it 'should include a new snapshot option' do
      helper.options_for_deployables(@deployables).should have_tag('option', :text => /[Nn]ew/)
    end
    
    it 'should include an option for each deployable with the id, last deployment time, and last deployment reason' do
      result = helper.options_for_deployables(@deployables)
      @deployables.each do |deployable|
        result.should have_tag('option[value=?]', deployable.id.to_s, :text => /#{deployable.last_deployment_reason}.*#{deployable.last_deployment_time}/)
      end
    end
  end
end