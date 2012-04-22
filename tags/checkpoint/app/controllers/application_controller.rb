class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  rescue_from ActionController::RoutingError, :with => :render_404
  
  def not_found
    raise ActionController::RoutingError.new('Not Found')
    render 
  end

  def render_404
    respond_to do |type| 
      type.html { render :template => "/errors/404.html", :status => 404 } 
      type.all  { render :nothing => true, :status => 404 } 
    end
    true
  end
end
