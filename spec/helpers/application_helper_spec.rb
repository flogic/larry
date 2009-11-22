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
  
  it 'should be able to present a really brief version of a model instance' do
    helper.should respond_to(:brief)
  end
  
  describe 'when presenting a really brief version of a model instance' do
    it 'should accept a model instance' do
      lambda { helper.brief(:foo) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a model instance' do
      lambda { helper.brief }.should raise_error(ArgumentError)
    end
    
    it 'should fail when an empty model instance is given' do
      lambda { helper.brief(nil) }.should raise_error
    end

    it 'should return a link to the model instance with the model name as the link body if model has a name' do
      instance = Customer.generate!
      helper.brief(instance).should == link_to(instance.name, customer_path(instance))
    end
    
    it 'should return a link to the model instance with the model as a string as the link body if model has no name' do
      instance = Deployment.generate!
      helper.brief(instance).should == link_to(instance.to_s, deployment_path(instance))
    end
  end
  
  it 'should be able to generate a list of brief versions of model instances' do
    helper.should respond_to(:list)
  end
  
  describe 'when generating a list of brief versions of model instances' do
    it 'should accept a list of model instances' do
      lambda { helper.list(:foo) }.should_not raise_error(ArgumentError)
    end

    it 'should return the empty string when the list of model instances is empty' do
      helper.list().should == ''
    end
    
    it 'should return the empty string when the list of model instances is blank' do
      helper.list([]).should == ''
    end
    
    it 'should return a ","-joined list of the brief versions of the provided model instances when passed as an array' do
      instances = [ Customer.generate!, Host.generate!, Deployment.generate!, App.generate! ]
      helper.list(instances).should == instances.collect {|i| helper.brief(i)}.join(", ")
    end
    
    it 'should return a ","-joined list of the brief versions of the provided model instances when passed as separate arguments' do
      instances = [ Customer.generate!, Host.generate!, Deployment.generate!, App.generate! ]
      helper.list(*instances).should == instances.collect {|i| helper.brief(i)}.join(", ")
    end
  end
  
  it 'should be able to display a tree' do
    helper.should respond_to(:display_tree)
  end
  
  describe 'when displaying a tree' do
    it 'should accept a tree' do
      lambda { helper.display_tree([]) }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a tree' do
      lambda { helper.display_tree }.should raise_error(ArgumentError)      
    end
    
    it 'should return the empty string when the tree is empty' do
      helper.display_tree([]).should == ''
    end

    it 'should return an unordered list with a list element for each tree node when the tree is flat' do
      tree = Array.new(3) { Customer.generate! }
      response = helper.display_tree(tree)
      response.should have_tag('ul') do
        tree.each do |customer|
          with_tag('li', :text => Regexp.new(customer.name))
        end
      end
    end
    
    it 'should have more behavior'
  end
end
