class UserSessionsController < ApplicationController
  #this receives browser info from a jquery request and stores time zone info in the session
  def compute_time_zone_offset
    offset_seconds = params[:offset_minutes].to_i * 60
    @time_zone = ActiveSupport::TimeZone[offset_seconds] || ActiveSupport::TimeZone["UTC"]
    session[:time_zone_name] = @time_zone.name
    render :text => "success"
  end
end
