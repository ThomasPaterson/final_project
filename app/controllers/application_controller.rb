class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include ApplicationHelper
  include ListsHelper
  include RemindersHelper
  include UsersHelper
  
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
  
  #if the current session is admin, allows, otherwise forbids
  def admin_required  
	unless current_user && (current_user.id < 1 || current_user.permission_level == 1)  
      redirect_to '/'  
    end  
  end
  
  #if the current session is admin or the owner, allows, otherwise forbids
  def admin_or_owner_required(id)
    unless current_user.id == id || current_user.id == 1 || current_user.permission_level == 1
      redirect_to '/'  
    end  
  end 

end
