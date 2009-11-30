class DeploymentsController < ApplicationController
  resources_controller_for :deployment, :except => [ :new, :create ]
  
  before_filter :lookup_instance, :only => [ :new, :create ]
  
  def lookup_instance
    @instance = Instance.find(params[:instance_id])
  end
  
  # GET /deployments/new
  def new
    @deployment = Deployment.new(params[:deployment])

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.xml  { render :xml => @deployment }
    end
  end
  
  # POST /deployments
  # POST /deployments.xml
  def create
    @deployment = Deployment.new(params[:deployment])
    @deployment.deployable = Deployable.create!(:instance => @instance)

    respond_to do |format|
      if @deployment.save
        format.html do
          flash[:notice] = "Deployment was successfully created."
          redirect_to deployment_path(@deployment)
        end
        format.js
        format.xml  { render :xml => @deployment, :status => :created, :location => deployment_url(@deployment) }
      else
        format.html { render :action => "new" }
        format.js   { render :action => "new" }
        format.xml  { render :xml => @deployment.errors, :status => :unprocessable_entity }
      end
    end
  end
end
