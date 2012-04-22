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
    
  def owner?(id)  
    if current_user.id == id  
      return true  
    else  
      return false  
    end  
  end 

  def get_user 
   if params[:user_id].nil?
  	current_user
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
    base_title = "Ruby on Rails"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  # Convert a given date by the specified time zone
  # and return a formatted date
  # e.g. March 27, 2012 09:12 AM PDT
  def nice_format(date, zone)
    date.in_time_zone(zone).strftime('%B %d, %Y %l:%M %p %Z')
  end
    

  # Convert a given date by the specified time zone
  # and return a formatted date
  # e.g. 03/27 @ 09:12, Today @ 09:12, Now
  def dash_nice_format(date, zone)
    if date.strftime('%d') == Time.now.strftime('%d')
      # the given day is today
      if date.strftime('%l:%M') < Time.now.strftime('%l:%M')
        # the time specified in date has already passed
        'Now'
      else
        # the time has not passed yet
        date.in_time_zone(zone).strftime('Today @ %l:%M')
      end
    else
      # the given date is sometime in the future
      date.in_time_zone(zone).strftime('%m/%d @ %l:%M')
    end
  end
end
