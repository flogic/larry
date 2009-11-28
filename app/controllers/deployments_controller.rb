class DeploymentsController < ApplicationController
  resources_controller_for :deployment, :in => :instance
  resources_controller_for :deployment
end
