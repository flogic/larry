class HostsController < ApplicationController
  resources_controller_for :host
  
  def configuration
    @host = Host.find_by_name!(params[:name])
    respond_to do |format|
      format.html { redirect_to host_url(@host) }
      format.pp   { render :text => @host.puppet_manifest }
      format.json { render :json => @host.configuration.to_json }
      format.yaml { render :text => @host.configuration.to_yaml }
    end
  end
end
