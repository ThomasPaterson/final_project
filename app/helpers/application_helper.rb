module ApplicationHelper
	
  def logo
    image_tag("rails.png", :alt => "Sample App", :class => "round")
  end
  
  def admin?  
    if current_user.permission_level == 1 
      return true  
    else  
      return false  
    end  
  end  

  def banned? 
    is_banned(current_user)  
  end 

  def is_banned(user)  
    if user.permission_level == 10
      return true  
    else  
      return false  
    end  
  end  
    
  def owner?(id)  
    if current_user.id == id  
       true  
    end  
    false  
  end 
  
  
  #returns if a filter is on based on url
  def check_filter(url, searchstring)
  	
	if !(url.include?(searchstring))
  	  false
  	else
  	  true
  	end
  	
  end
  

  
  #gets the user from the url params, uses the current user as a default
  def get_user 
   if params[:user_id].nil?
  	current_user
    else
      User.find(params[:user_id])
    end
  end   
  
  #gets the user from the url params, checks both user_id and the id params
  def get_effected_user
   if params[:user_id].nil?
   	
   	  if params[:id].nil?
  	    User.find(params[:user][:id])
  	  else
  	  	User.find(params[:id])
  	  end
  	  
    else
      User.find(params[:user_id])
    end
  end   
    
  def admin_or_owner?(id)  
    if (admin? || owner?(id))  
      return true  
    else  
      return false  
    end  
  end 

  # Return a title on a per-page basis.
  def title
    base_title = "Plan It"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  # Convert a given date by the specified time zone
  # and return a formatted date
  # e.g. March 27, 2012 09:12 AM
  def nice_format(date, zone)
    date.in_time_zone(zone).strftime('%B %d, %Y @ %l:%M %p')
  end

  # Convert a given date to an easy-to-read format
  # e.g. March 27, 2012
  def nice_format_no_time(date)
    date.strftime('%B %d, %Y')
  end

  # Convert a given date by the specified time zone
  # and return a formatted date
  # e.g. 03/27 @ 09:12, Today @ 09:12, Now
  def dash_nice_format(date, zone)
    if date.strftime('%d%m%Y') == Time.now.strftime('%d%m%Y')
      # the given day is today
      if date.strftime('%H:%M') < Time.now.strftime('%H:%M')
        # the time specified in date has already passed
        'Now'
      else
        # the time has not passed yet
        date.in_time_zone(zone).strftime('@ %l:%M %p')
      end
    else
      # the given date is sometime in the future
      date.in_time_zone(zone).strftime('%a %d/%m')
    end
  end
end
