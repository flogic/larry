class DeploymentsController < ApplicationController
  resources_controller_for :deployment, :except => [ :new, :create ]
end
