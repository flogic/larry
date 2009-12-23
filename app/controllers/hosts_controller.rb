class HostsController < ApplicationController
  resources_controller_for :host
  
  before_filter :extract_format_from_hostname, :only => [ :configuration ]
  
  def configuration
    @host = Host.find_by_name!(params[:name])
    respond_to do |format|
      format.html { redirect_to host_url(@host) }
      format.pp   { render :text => @host.puppet_manifest }
      format.json { render :json => @host.configuration.to_json }
      format.yaml { render :text => @host.configuration.to_yaml }
    end
  end
  
  protected
  
  def extract_format_from_hostname
    return unless params[:name].first =~ /\./
    return unless params[:format].blank?
    params[:name], params[:format] = (Regexp.new(/^(.*)\.([^.]*)$/).match(params[:name].first)[1..2])
  end
end
