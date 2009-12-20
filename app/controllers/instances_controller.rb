class InstancesController < ApplicationController
  resources_controller_for :instance, :in => :app
  resources_controller_for :instance
  
  def new_deployment
    @instance = Instance.find(params[:id])
    @hosts = Host.all
    render :layout => false
  end

  def deploy
    @instance = Instance.find(params[:id])
    if @instance.can_deploy?
      begin
        @instance.deploy(params[:deployment], params[:deployable])
        @host = Host.find(params[:deployment]["host_id"])
        flash[:notice] = "Instance successfully deployed to host #{@host.name}"
      rescue Exception => e
        flash[:error] = "Instance deployment failed: #{e.to_s}"
      end
    else
      flash[:error] = "Instance cannot be deployed -- ensure that it has services and all required parameters are set."
    end
      
    redirect_to instance_path(@instance) 
  end
  
  before_filter :unserialize_parameters_data, :only => [ :create, :update ]
  
  protected
  
  # take key-value data from params[:instance]['parameters'] and return the corresponding instance#parameters hash
  def unserialize_parameters_data
    if params[:instance]['parameters'] and params[:instance]['parameters']['key'] and params[:instance]['parameters']['value']
      params[:instance]['parameters'] = params[:instance]['parameters']['key'].zip(params[:instance]['parameters']['value']).inject({}) do |h, pair|
        h[pair.first] = pair.last unless pair.first.blank? or pair.last.blank?
        h
      end
    else
      params[:instance]['parameters'] = {}
    end
  end
end
