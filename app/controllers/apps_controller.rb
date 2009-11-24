class AppsController < ApplicationController
  resources_controller_for :app, :in => :customer
  resources_controller_for :app
end
