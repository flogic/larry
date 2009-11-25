class CustomersController < ApplicationController
  resources_controller_for :customer
  
  before_filter :unserialize_parameters_data, :only => [ :create, :update ]
  
  # take key-value data from params[:customer]['parameters'] and return the corresponding customer#parameters hash
  def unserialize_parameters_data
    if params[:customer]['parameters'] and params[:customer]['parameters']['key'] and params[:customer]['parameters']['value']
      params[:customer]['parameters'] = params[:customer]['parameters']['key'].zip(params[:customer]['parameters']['value']).inject({}) do |h, pair|
        h[pair.first] = pair.last unless pair.first.blank?
        h
      end
    else
      params[:customer]['parameters'] = {}
    end
  end
end
