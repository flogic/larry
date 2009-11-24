class InstancesController < ApplicationController
  resources_controller_for :instance, :in => :app
  resources_controller_for :instance
end
