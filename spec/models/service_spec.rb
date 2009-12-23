require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Service do
  describe 'attributes' do
    before :each do
      @service = Service.new
    end
    
    it 'should have a name' do
      @service.should respond_to(:name)
    end
    
    it 'should allow setting and retrieving the name' do
      @service.name = 'test name'
      @service.name.should == 'test name'
    end

    it 'should have a description' do
      @service.should respond_to(:description)
    end

    it 'should allow setting and retrieving the description' do
      @service.description = 'test description'
      @service.description.should == 'test description'
    end
    
    it 'should have a list of required parameter names' do
      @service.should respond_to(:parameters)
    end
    
    it 'should allow setting and retrieving the list of required parameter names' do
      @service.parameters = [ 'VHost name', 'SSL_required' ]
      @service.parameters.should == [ 'VHost name', 'SSL_required' ]
    end
    
    it 'should preserve the list of required parameter names as a list' do
      @service = Service.generate!(:parameters => [ 'VHost name', 'SSL_required' ])
      Service.find(@service.id).parameters.first.should == 'VHost name'    
    end
    
    it 'should return an empty list for parameters when parameters are empty' do
      @service.parameters = nil
      @service.parameters.should == []
    end
  end

  describe 'validations' do
    before :each do
      @service = Service.new
    end

    it 'should require a name' do
      @service.name = nil
      @service.valid?
      @service.errors.should be_invalid(:name)
    end
    
    it 'should require name to be unique' do
      dup = Service.generate!(:name => 'unoriginal name')
      @service.name = 'unoriginal name'
      @service.valid?
      @service.errors.should be_invalid(:name)
    end

    it 'should be valid with an unique name' do
      @service.name = 'creative name'
      @service.valid?
      @service.errors.should_not be_invalid(:name)
    end
  end
  
  describe 'associations' do
    before :each do
      @service = Service.new
    end
    
    it 'should have many instances' do
      @service.should respond_to(:instances)
    end
    
    it 'should allow setting and retrieving instances' do
      @service.instances << instances = Array.new(2) { Instance.generate! }
      @service.instances.should == instances
    end
    
    it 'should have many deployables' do
      @service.should respond_to(:deployables)
    end
    
    it "should return its instances' deployables when looking up deployables" do
      deployables = Array.new(2) { Deployable.generate! }
      @service.instances << deployables.collect(&:instance)
      @service.deployables.sort_by(&:id).should == deployables.sort_by(&:id)
    end
        
    it 'should have many deployments' do
      @service.should respond_to(:deployments)
    end
    
    it "should return its instances' deployments when looking up deployments" do
      deployments = Array.new(2) { Deployment.generate! }
      @service.instances << deployments.collect(&:instance)
      @service.deployments.sort_by(&:id).should == deployments.sort_by(&:id)
    end
        
    it 'should have many hosts' do
      @service.should respond_to(:hosts)
    end
    
    it "should return its instances' hosts when looking up hosts" do
      deployed_services = Array.new(2) { DeployedService.generate! }
      @service.instances << deployed_services.collect(&:instance)
      @service.hosts.sort_by(&:id).should == deployed_services.collect(&:host).sort_by(&:id)
    end

    it 'should have many apps' do
      @service.should respond_to(:apps)      
    end
    
    it "should return its instances' apps when looking up apps" do
      @service.instances << instances = Array.new(2) { Instance.generate! }
      @service.apps.sort_by(&:id).should == instances.collect(&:app).sort_by(&:id)            
    end
    
    it 'should have many customers' do
      @service.should respond_to(:customers)
    end
    
    it "should return its instances' customers when looking up customers" do
      @service.instances << instances = Array.new(2) { Instance.generate! }
      @service.customers.sort_by(&:id).should == instances.collect(&:customer).sort_by(&:id)      
    end
  end
  
  describe 'relationships' do
    before :each do
      @service = Service.new
    end

    it 'should have many edges as a source' do
      @service.should respond_to(:source_edges)
    end

    it 'should allow assigning edges as a source' do
      @service = Service.generate!
      @service.source_edges.generate!
      @service.source_edges.should_not be_empty
    end

    it 'should have many edges as a target' do
      @service.should respond_to(:target_edges)
    end

    it 'should allow assigning edges as a target' do
      @service = Service.generate!
      @service.target_edges.generate!
      @service.target_edges.should_not be_empty
    end
    
    it 'should have many "depends on" edges' do
      @service.should respond_to(:depends_on_edges)
    end

    it 'should allow assigning "depends on" edges' do
      @service = Service.generate!
      @service.depends_on_edges.generate!
      @service.depends_on_edges.should_not be_empty
    end

    it 'should have many "dependent" edges' do
      @service.should respond_to(:dependent_edges)
    end

    it 'should allow assigning "dependent" edges' do
      @service = Service.generate!
      @service.dependent_edges.generate!
      @service.dependent_edges.should_not be_empty
    end

    it 'should have many services it depends on' do
      @service.should respond_to(:depends_on)
    end

    it 'should allow assigning services it depends on' do
      @service = Service.generate!
      @other = Service.generate!
      @service.depends_on << @service
      @service.depends_on.should include(@service)
    end

    it 'should have many dependent services' do
      @service.should respond_to(:dependents)
    end

    it 'should allow assigning dependent services' do
      @service = Service.generate!
      @other = Service.generate!
      @other.dependents << @service
      @other.dependents.should include(@service)
    end
    
    it 'should be able to find all services it depends on' do
      @service.should respond_to(:all_depends_on)
    end
    
    it 'should be able to find all services that depend on it' do
      @service.should respond_to(:all_dependents)
    end
    
    describe 'with dependencies' do
      before :each do
        @service     = Service.generate!(:name => 'service')
        @parent      = Service.generate!(:name => 'parent')
        @grandparent = Service.generate!(:name => 'grandparent')
        @child       = Service.generate!(:name => 'child')
        @grandchild  = Service.generate!(:name => 'grandchild')
        @service.dependents << @parent
        @parent.dependents  << @grandparent
        @service.depends_on << @child
        @child.depends_on   << @grandchild
      end
      
      it 'should not include itself when finding all services it depends on' do
        @service.all_depends_on.should_not include(@service)
      end
      
      it 'should include services that it directly depends on when finding all services that it depends on' do
        @service.all_depends_on.should include(@child)
      end
    
      it 'should return all reachable services when finding all services that it depends on' do
        @service.all_depends_on.should include(@grandchild)      
      end
      
      it 'should only return a single instance of a service that appears multiple times when finding all services that it depends on' do
        @service.depends_on << @grandchild
        @service.all_depends_on.select {|s| s == @grandchild }.size.should == 1
      end
    
      it 'should not include itself when finding all services it depends on' do
        @service.all_dependents.should_not include(@service)
      end
    
      it 'should include services that directly depend on it when finding all services that depend on it' do
        @service.all_dependents.should include(@parent)
      end

      it 'should return all reachable services when finding all services that depend on it' do
        @service.all_dependents.should include(@grandparent)
      end

      it 'should only return a single instance of a service that appears multiple times when finding all services that depend on it' do
        @service.dependents << @grandparent
        @service.all_dependents.select {|s| s == @grandparent }.size.should == 1
      end
      
      it 'should be able to tell if a service is a root service' do
        @service.should respond_to(:root?)
      end
      
      it 'should not be a root service if it has services which depend on it' do
        @grandparent.should be_root
      end
      
      it 'should be a root service if it has no services which depend on it' do
        @parent.should_not be_root
      end
      
      it 'should be able to tell if a service is a leaf service' do
        @service.should respond_to(:leaf?)
      end
      
      it 'should not be a leaf service if it has services which it depends on' do
        @grandchild.should be_leaf
      end
      
      it 'should be a leaf service if it has no services which it depends on' do
        @child.should_not be_leaf
      end
    end    
  end
  
  describe 'as a class' do
    it 'should be able to return a list of services unrelated to another list of services' do
      Service.should respond_to(:unrelated_services)
    end
    
    describe 'when returning a list of services unrelated to another list of services' do
      before :all do
        Service.delete_all
      end
      
      it 'should accept a list of services' do
        lambda { Service.unrelated_services([]) }.should_not raise_error(ArgumentError)
      end

      it 'should return all services if the service list is empty' do
        unrelated = Array.new(2) { Service.generate! }
        Service.unrelated_services([]).should == unrelated
      end
      
      it 'should return those services unrelated to the services in the list' do
        known = Array.new(2) { Service.generate! }
        unrelated = Array.new(2) { Service.generate! }
        Service.unrelated_services(known).should == unrelated
      end
      
      it 'should return those services unrelated to the services in the list even when the list is passed as separate arguments' do
        known = Array.new(2) { Service.generate! }
        unrelated = Array.new(2) { Service.generate! }
        Service.unrelated_services(*known).should == unrelated        
      end
    end
  end
  
  it 'should be able to return a "tree" of services we depend on' do
    Service.new.should respond_to(:depends_on_tree)
  end
  
  describe 'when returning a "tree" of services we depend on' do
    before :each do
      @service = Service.generate!
    end
    
    it 'should work without arguments' do
      lambda { @service.depends_on_tree }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @service.depends_on_tree(:foo) }.should raise_error(ArgumentError)      
    end
    
    it 'should return an empty list if we do not depend on services' do
      @service.depends_on_tree.should == []
    end
    
    it 'should return a list of the services we depend on when there are no deeper nestings' do
      others = Array.new(2) { Service.generate! }
      @service.depends_on << others
      @service.depends_on_tree.should == others
    end
    
    it 'should nest any depends_on relationships as nested arrays' do
      kids = Array.new(2) { Service.generate! }
      grandkids = Array.new(2) { Service.generate! }
      kids.first.depends_on << grandkids
      @service.depends_on << kids
      @service.depends_on_tree.should == [ kids.first, grandkids, kids.last ]      
    end
  end
  
  it 'should be able to return a "tree" of services that depend on us' do
    Service.new.should respond_to(:dependents_tree)
  end
  
  describe 'when returning a "tree" of services that depend on us' do
    before :each do
      @service = Service.generate!
    end
    
    it 'should work without arguments' do
      lambda { @service.dependents_tree }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @service.dependents_tree(:foo) }.should raise_error(ArgumentError)      
    end
    
    it 'should return an empty list if we do not depend on services' do
      @service.dependents_tree.should == []
    end
    
    it 'should return a list of the services we depend on when there are no deeper nestings' do
      others = Array.new(2) { Service.generate! }
      @service.dependents << others
      @service.dependents_tree.should == others
    end
    
    it 'should nest any depends_on relationships as nested arrays' do
      parents = Array.new(2) { Service.generate! }
      grandparents = Array.new(2) { Service.generate! }
      parents.first.dependents << grandparents
      @service.dependents << parents
      @service.dependents_tree.should == [ parents.first, grandparents, parents.last ]      
    end
  end
  
  it 'should be able to return a list of services unrelated to this service' do
    Service.new.should respond_to(:unrelated)
  end
  
  describe 'when returning a list of services unrelated to this service' do
    before :all do
      Service.delete_all
    end
    
    before :each do
      @service = Service.generate!
    end
    
    it 'should not require arguments' do
      lambda { @service.unrelated }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @service.unrelated(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should not return the service itself' do
      @service.unrelated.should_not include(@service)
    end
    
    it 'should not return services which this service depends on' do
      others = Array.new(2) { Service.generate! }
      @service.depends_on << others
      result = @service.unrelated
      others.each do |other|
        result.should_not include(other)
      end
    end
    
    it 'should not return services which this service has a transitive dependency on' do
      intermediate = Service.generate!
      others = Array.new(2) { Service.generate! }
      intermediate.depends_on << others
      @service.depends_on << intermediate
      result = @service.unrelated
      others.each do |other|
        result.should_not include(other)
      end      
    end
    
    it 'should not return services which depend on this service' do
      others = Array.new(2) { Service.generate! }
      @service.dependents << others
      result = @service.unrelated
      others.each do |other|
        result.should_not include(other)
      end
    end
    
    it 'should not return services which have a transitive dependency on this service' do
      intermediate = Service.generate!
      others = Array.new(2) { Service.generate! }
      intermediate.dependents << others
      @service.dependents << intermediate
      result = @service.unrelated
      others.each do |other|
        result.should_not include(other)
      end      
    end
    
    it 'should return all services which have no depency relationship with this service' do
      unrelateds = Array.new(2) { Service.generate! }
      result = @service.unrelated
      unrelateds.each do |unrelated|
        result.should include(unrelated)
      end
    end
  end
  
  it 'should be possible to find an edge to another service' do
    Service.new.should respond_to(:edge_to)
  end
  
  describe 'when finding an edge to another service' do
    before :each do
      @service = Service.generate!
    end
    
    it 'should accept a service' do
      lambda { @service.edge_to(@service) }.should_not raise_error(ArgumentError)
    end

    it 'should require a service' do
      lambda { @service.edge_to }.should raise_error(ArgumentError)      
    end

    it 'should return nil if the service cannot be located' do
      @service.edge_to(Service.new).should be_nil
    end
    
    it 'should return nil if there is no edge from this service to the other service' do
      @service.edge_to(Service.generate!).should be_nil
    end
    
    it 'should return nil if there is no edge in the proper direction from this service to the other service' do
      other = Service.generate!
      other.depends_on << @service
      @service.edge_to(other).should be_nil      
    end
    
    it 'should return the edge from this service to the other service' do
      other = Service.generate!
      other.dependents << @service
      result = @service.edge_to(other)
      result.source.should == @service
      result.target.should == other
    end
  end

  it 'should be possible to find an edge from another service' do
    Service.new.should respond_to(:edge_from)
  end
  
  describe 'when finding an edge from another service' do
    before :each do
      @service = Service.generate!
    end
    
    it 'should accept a service' do
      lambda { @service.edge_from(@service) }.should_not raise_error(ArgumentError)
    end

    it 'should require a service' do
      lambda { @service.edge_from }.should raise_error(ArgumentError)      
    end

    it 'should return nil if the service cannot be located' do
      @service.edge_from(Service.new).should be_nil
    end

    it 'should return nil if there is no edge from this service to the other service' do
      @service.edge_from(Service.generate!).should be_nil
    end
    
    it 'should return nil if there is no edge in the proper direction from the other service to this service' do
      other = Service.generate!
      other.dependents << @service
      @service.edge_from(other).should be_nil      
    end
    
    it 'should return the edge from the other service to this service' do
      other = Service.generate!
      other.depends_on << @service
      result = @service.edge_from(other)
      result.source.should == other
      result.target.should == @service
    end
  end
  
  it 'should have a means to determine if it is safe to delete this service' do
    Service.new.should respond_to(:safe_to_delete?)
  end

  describe 'when determining if it is safe to delete this service' do
    before :each do
      @service = Service.generate!
    end

    it 'should work without arguments' do
      lambda { @service.safe_to_delete? }.should_not raise_error(ArgumentError)
    end

    it 'should not accept arguments' do
      lambda { @service.safe_to_delete?(:foo) }.should raise_error(ArgumentError)      
    end

    it 'should return false if the service has dependents' do
      @service.dependents << Array.new(2) { Service.generate! }
      @service.safe_to_delete?.should be_false
    end
    
    it 'should return false if the service depends on other services' do
      @service.depends_on << Array.new(2) { Service.generate! }
      @service.safe_to_delete?.should be_false
    end

    it 'should return false if the service is required by some instance' do
      @service.requirements.generate!
      @service.safe_to_delete?.should be_false      
    end

    it 'should return true if the service has no deployements' do
      @service.safe_to_delete?.should be_true
    end
  end

  describe 'when deleting' do
    before :each do
      @service = Service.generate!
    end

    it 'should not allow deletion when it is not safe to delete' do
      @service.stubs(:safe_to_delete?).returns(false)
      lambda { @service.destroy }.should_not change(Service, :count)
    end

    it 'should allow deletion when it is safe to delete' do
      @service.stubs(:safe_to_delete?).returns(true)
      lambda { @service.destroy }.should change(Service, :count)    
    end
  end
  
  it 'should be able to return a list of all the parameter names needed, including dependencies' do
    Service.new.should respond_to(:needed_parameters)
  end
  
  describe 'when returning a list of all the parameter names needed, including dependencies' do
    before :each do
      @service = Service.generate!
    end
    
    it 'should work without arguments' do
      lambda { @service.needed_parameters }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @service.needed_parameters(:foo) }.should raise_error(ArgumentError)      
    end
    
    it 'should return the empty list if we have no parameters and we depend on no other services' do
      @service.parameters = nil
      @service.needed_parameters.should == []
    end
    
    it 'should return the empty list if our parameters are empty and we depend on no other services' do
      @service.parameters = []
      @service.needed_parameters.should == []
    end
    
    it 'should return our parameters list if we depend on no other services' do
      @service.parameters = [ 'field 1', 'field 2' ]
      @service.needed_parameters.sort.should == [ 'field 1', 'field 2' ]
    end
    
    it 'should return the union of our parameter list and those of the services we depend on' do
      @service.parameters = [ 'field 1', 'field 2' ]
      @service.depends_on << kids = Array.new(3) { Service.generate! }
      kids.first.parameters = [ 'field 3', 'field 4' ]
      kids.last.parameters = [ 'field 5', 'field 6' ]
      kids.first.save!
      kids.last.save!
      @service.needed_parameters.sort.should == [ 'field 1', 'field 2', 'field 3', 'field 4', 'field 5', 'field 6' ]      
    end
    
    it 'should not include duplicate parameters' do
      @service.parameters = [ 'field 1', 'field 2' ]
      @service.depends_on << kids = Array.new(3) { Service.generate! }
      kids.first.parameters = [ 'field 3', 'field 4' ]
      kids.last.parameters = [ 'field 4', 'field 5' ]
      kids.first.save!
      kids.last.save!
      @service.needed_parameters.sort.should == [ 'field 1', 'field 2', 'field 3', 'field 4', 'field 5' ]            
    end
    
    it 'should not include empty parameters' do
      @service.parameters = [ 'field 1', 'field 2' ]
      @service.depends_on << kids = Array.new(3) { Service.generate! }
      kids.first.parameters = [ 'field 3', 'field 4' ]
      kids.last.parameters = [ 'field 4', nil]
      kids.first.save!
      kids.last.save!
      @service.needed_parameters.sort.should == [ 'field 1', 'field 2', 'field 3', 'field 4' ]                  
    end
  end

  it 'should be able to return a list of all the parameter names needed by only our dependencies' do
    Service.new.should respond_to(:depends_on_additional_parameters)
  end
  
  describe 'when returning a list of all the parameter names needed by only our dependencies' do
    before :each do
      @service = Service.generate!
    end
    
    it 'should work without arguments' do
      lambda { @service.depends_on_additional_parameters }.should_not raise_error(ArgumentError)
    end
    
    it 'should not allow arguments' do
      lambda { @service.depends_on_additional_parameters(:foo) }.should raise_error(ArgumentError)      
    end
    
    it 'should return the empty list if we have no parameters and we depend on no other services' do
      @service.parameters = nil
      @service.depends_on_additional_parameters.should == []
    end
    
    it 'should return the empty list if our parameters are empty and we depend on no other services' do
      @service.parameters = []
      @service.depends_on_additional_parameters.should == []
    end
    
    it 'should return the empty list if we depend on no other services' do
      @service.parameters = [ 'field 1', 'field 2' ]
      @service.depends_on_additional_parameters.sort.should == []
    end
    
    it 'should return the union of the parameter lists of the services we depend on' do
      @service.parameters = [ 'field 1', 'field 2' ]
      @service.depends_on << kids = Array.new(3) { Service.generate! }
      kids.first.parameters = [ 'field 3', 'field 4' ]
      kids.last.parameters = [ 'field 5', 'field 6' ]
      kids.first.save!
      kids.last.save!
      @service.depends_on_additional_parameters.sort.should == [ 'field 3', 'field 4', 'field 5', 'field 6' ]      
    end
    
    it 'should not include duplicate parameters' do
      @service.parameters = [ 'field 1', 'field 2' ]
      @service.depends_on << kids = Array.new(3) { Service.generate! }
      kids.first.parameters = [ 'field 3', 'field 4' ]
      kids.last.parameters = [ 'field 4', 'field 5' ]
      kids.first.save!
      kids.last.save!
      @service.depends_on_additional_parameters.sort.should == [ 'field 3', 'field 4', 'field 5' ]            
    end
    
    it 'should not include empty parameters' do
      @service.parameters = [ 'field 1', 'field 2' ]
      @service.depends_on << kids = Array.new(3) { Service.generate! }
      kids.first.parameters = [ 'field 3', 'field 4' ]
      kids.last.parameters = [ 'field 4', nil]
      kids.first.save!
      kids.last.save!
      @service.depends_on_additional_parameters.sort.should == [ 'field 3', 'field 4' ]                  
    end
    
    it 'should not include parameters from services we depend on that we already require' do
      @service.parameters = [ 'field 1', 'field 2' ]
      @service.depends_on << kids = Array.new(3) { Service.generate! }
      kids.first.parameters = [ 'field 2', 'field 4' ]
      kids.last.parameters = [ 'field 5', 'field 6' ]
      kids.first.save!
      kids.last.save!
      @service.depends_on_additional_parameters.sort.should == [ 'field 4', 'field 5', 'field 6' ]      
    end
  end
end
