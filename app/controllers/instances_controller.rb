class InstancesController < ApplicationController
  resources_controller_for :instance, :in => :app
  resources_controller_for :instance
  
  before_filter :unserialize_parameters_data, :only => [ :create, :update ]
  
  # take key-value data from params[:instance]['parameters'] and return the corresponding instance#parameters hash
  def unserialize_parameters_data
    if params[:instance]['parameters'] and params[:instance]['parameters']['key'] and params[:instance]['parameters']['value']
      params[:instance]['parameters'] = params[:instance]['parameters']['key'].zip(params[:instance]['parameters']['value']).inject({}) do |h, pair|
        h[pair.first] = pair.last unless pair.first.blank?
        h
      end
    else
      params[:instance]['parameters'] = {}
    end
  end
end
