# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :init_time_zone
  
  #sets the time zone for this request if a session time zone exists if it doesn't the default is UTC
  def init_time_zone
    if session[:time_zone_name]
      @time_zone = ActiveSupport::TimeZone[session[:time_zone_name]]
      Time.zone = @time_zone.name if @time_zone
    end
    true
  end
  protected :init_time_zone
end
