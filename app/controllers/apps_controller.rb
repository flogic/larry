class AppsController < ApplicationController
  resources_controller_for :app, :in => :customer
  resources_controller_for :app
  
  before_filter :unserialize_parameters_data, :only => [ :create, :update ]
  
  # take key-value data from params[:app]['parameters'] and return the corresponding app#parameters hash
  def unserialize_parameters_data
    if params[:app]['parameters'] and params[:app]['parameters']['key'] and params[:app]['parameters']['value']
      params[:app]['parameters'] = params[:app]['parameters']['key'].zip(params[:app]['parameters']['value']).inject({}) do |h, pair|
        h[pair.first] = pair.last unless pair.first.blank?
        h
      end
    else
      params[:app]['parameters'] = {}
    end
  end
end
