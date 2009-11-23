class RequirementsController < ApplicationController
  
  # POST /requirements?instance_id=1&service_id=2
  def create
    @instance = Instance.find(params[:requirement][:instance_id])
    @service = Service.find(params[:requirement][:service_id])
    @requirement = Requirement.create!(:instance => @instance, :service => @service)
    
    respond_to do |format|
      format.html { redirect_to instance_path(@instance) }
      format.js
      format.xml  { render :xml => @edge, :status => :created, :location => requirement_url(@requirement) }
    end
  end

  # DELETE /requirements/1
  # DELETE /requirements/1.xml
  def destroy
    @requirement = Requirement.find(params[:id])
    @instance = @requirement.instance
    @requirement.destroy
    respond_to do |format|
      format.html { redirect_to instance_path(@instance) }
      format.js
      format.xml  { head :ok }
    end
  end
end
