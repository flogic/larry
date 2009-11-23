class EdgesController < ApplicationController
  
  # POST /edges?edge[source_id]=1&edge[target_id]=2
  def create
    @source = Service.find(params[:edge][:source_id])
    @target = Service.find(params[:edge][:target_id])
    @edge = Edge.create!(:source => @source, :target => @target)
    
    respond_to do |format|
      format.html { redirect_to service_path(@source) }
      format.js
      format.xml  { render :xml => @edge, :status => :created, :location => edge_url(@edge) }
    end
  end

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
end
