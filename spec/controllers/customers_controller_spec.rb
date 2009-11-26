require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CustomersController, 'when integrating' do
  integrate_views

  before :each do
    @customer = Customer.generate!
  end

  describe 'index' do
    def do_request
      get :index
    end

    it_should_behave_like "a successful action"
  end

  describe 'new' do
    def do_request
      get :new
    end

    it_should_behave_like "a successful action"
  end

  describe 'show' do
    def do_request
      get :show, :id => @customer.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'edit' do
    def do_request
      get :edit, :id => @customer.id.to_s
    end

    it_should_behave_like "a successful action"
  end

  describe 'create' do
    before :each do
      @customer = Customer.spawn
      @params = { :customer => @customer.attributes }
    end

    def do_request
      post :create, @params
    end

    it_should_behave_like "a redirecting action"
    
    describe 'when parameters are provided' do
      it 'should set the new customer parameters to an empty hash when the data provides no empty parameters list' do
        @params[:customer].delete('parameters')
        do_request
        Customer.find_by_name(@customer.name).parameters.should == {}
      end
      
      it 'should set the new customer parameters to an empty hash when the data provides an empty parameters list' do
        @params[:customer]['parameters'] = {}
        do_request
        Customer.find_by_name(@customer.name).parameters.should == {}
      end
      
      it 'should set the new customer parameters to an empty hash when the data provides no non-blank parameter names' do
        @params[:customer]['parameters'] = { 'key' => ['', '', ''], 'value' => ['1', '2', '3'] }
        do_request
        Customer.find_by_name(@customer.name).parameters.should == {}          
      end
      
      it 'should set the new customer parameters to a hash based on the data keys and values' do
        @params[:customer]['parameters'] = { 'key' => ['a', '', 'c'], 'value' => ['b', 'x', 'd'] }
        do_request
        Customer.find_by_name(@customer.name).parameters.should == { 'a' => 'b', 'c' => 'd' }                    
      end
      
      it 'should omit any parameter settings which have blank values' do
        @params[:customer]['parameters'] = { 'key' => ['a', 'j', 'c'], 'value' => ['b', '', 'd'] }
        do_request
        Customer.find_by_name(@customer.name).parameters.should == { 'a' => 'b', 'c' => 'd' }        
      end
    end
  end

  describe 'update' do
    before :each do
      @customer = Customer.generate!
      @params = { :id => @customer.id.to_s, :customer => @customer.attributes }
    end
    
    def do_request
      put :update, @params
    end

    it_should_behave_like "a redirecting action"
    
    describe 'when parameters are provided' do
      it 'should set the customer parameters to an empty hash when the data provides no empty parameters list' do
        @params[:customer].delete('parameters')
        do_request
        Customer.find(@customer.id).parameters.should == {}
      end
      
      it 'should set the customer parameters to an empty hash when the data provides an empty parameters list' do
        @params[:customer]['parameters'] = {}
        do_request
        Customer.find(@customer.id).parameters.should == {}
      end
      
      it 'should set the customer parameters to an empty hash when the data provides no non-blank parameter names' do
        @params[:customer]['parameters'] = { 'key' => ['', '', ''], 'value' => ['1', '2', '3'] }
        do_request
        Customer.find(@customer.id).parameters.should == {}          
      end
      
      it 'should set the customer parameters to a hash based on the data keys and values' do
        @params[:customer]['parameters'] = { 'key' => ['a', '', 'c'], 'value' => ['b', 'x', 'd'] }
        do_request
        Customer.find(@customer.id).parameters.should == { 'a' => 'b', 'c' => 'd' }                    
      end
      
      it 'should set the customer parameters to a hash based on the data keys and values' do
        @params[:customer]['parameters'] = { 'key' => ['a', 'j', 'c'], 'value' => ['b', '', 'd'] }
        do_request
        Customer.find(@customer.id).parameters.should == { 'a' => 'b', 'c' => 'd' }                    
      end
    end
  end

  describe 'destroy' do
    def do_request
      delete :destroy, :id => @customer.id.to_s
    end

    it_should_behave_like "a redirecting action"
  end
end

describe CustomersController, 'when not integrating' do
  it_should_behave_like 'a RESTful controller with an index action'
  it_should_behave_like 'a RESTful controller with a show action'
  it_should_behave_like 'a RESTful controller with a new action'
  it_should_behave_like 'a RESTful controller with an edit action'
  it_should_behave_like 'a RESTful controller with a destroy action'
end
