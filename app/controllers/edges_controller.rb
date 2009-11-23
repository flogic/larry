class EdgesController < ApplicationController
  resources_controller_for :edge, :except => [ :destroy, :link ]

  # DELETE /edge/1
  # DELETE /edge/1.xml
  def destroy
    @edge = Edge.find(params[:id])
    @source = @edge.source
    @edge.destroy
    respond_to do |format|
      format.html { redirect_to service_path(@source) }
      format.js
      format.xml  { head :ok }
    end
  end
  
  # POST /edges/link?source_id=1&target_id=2
  def link
    @source = Service.find(params[:source_id])
    @target = Service.find(params[:target_id])
    @edge = Edge.create!(:source => @source, :target => @target)
    
    respond_to do |format|
      format.html { redirect_to service_path(@source) }
      format.js
      format.xml  { render :xml => @edge, :status => :created, :location => edge_url(@edge) }
    end
  end
end
