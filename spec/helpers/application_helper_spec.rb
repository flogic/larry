require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe ApplicationHelper do
  it 'should be able to summarize a model instance' do
    helper.should respond_to(:summarize)
  end
  
  describe 'when summarizing a model instance' do
    it 'should allow passing a model instance' do
      lambda { helper.summarize(:foo) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a model instance' do
      lambda { helper.summarize }.should raise_error(ArgumentError)
    end
    
    it 'should fail if the model instance is empty' do
      lambda { helper.summarize(nil) }.should raise_error
    end
    
    it 'should render the summary partial for the class of the instance' do
      instance = Customer.generate!
      helper.expects(:render).with(has_entry(:partial, 'customers/summary'))
      helper.summarize(instance)
    end
    
    it 'should pass the instance as the named variable when rendering the summary partial' do
      instance = Customer.generate!
      helper.expects(:render).with(has_entry(:locals, { :customer => instance }))
      helper.summarize(instance)      
    end
  end
end
