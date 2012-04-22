module UsersHelper
  def gravatar_for(user, options = { :size => 50 })
    gravatar_image_tag(user.email.downcase, :alt => h(user.name),
                                            :class => 'gravatar',
                                            :gravatar => options)
  end
  
  def avatar_for(user, options = 50 )
  	
    if options.to_i == 50
      image_tag(user.photo.url(:small))
    elsif options.to_i == 75
      image_tag(user.photo.url(:medium))
  	else
  	  image_tag(user.photo.url(:thumb))
    end
  end

  def readable_permission_level(level)
  	if level == 1
  		return "Administrator"
  	elsif level == 2
  		return "Regular User"
    elsif level == 10
      return "Banned"
  	end
  end
  
  
  #gets tagfilter from url or returns nil if not there
  def check_tagfilter(params)
  	if params.nil?
  	  return nil
  	else
  	  return Array.new(params).uniq
  	end
  end
  
  #get time_units from url
  def check_timeunits(t_param, t_u_param)
  	if t_param.nil?
  	  "Week"
  	else
  	  t_u_param
  	end
  end
  
  #get time from url
  def check_time(param)
  	if param.nil?
  	  0
  	else
  	  param.to_i
  	end 	
  end
  
  
  #generates some pseudo random colors
  #by using a pattern, always generates the same colors to the same value if the filter hasn't been changed
  def generate_colors(num)
  	
  	@prng = Random.new(num)
  	@color_array = []
  	for i in 0..num
  		#not quite up to 999999 because we don't want it to be white on a white background
  		@r = @prng.rand * 800000 + 100000
  		@color_array <<  '#' + @r.to_i.to_s + ''
  	end
  	return @color_array
  end

  
  #gets the array of Stat_Array objects for the graph
  def get_line_points(time, time_units, filter_tag)

  	@stat_arrays = []


  	#gets the correct number of days based on time_units
  	if time_units == 'Week'
  	  @days = 1
  	  @timespan = 7
  	  @start_time = (@days*@timespan).days.ago.in_time_zone('GMT')
  	elsif time_units == 'Year'
  	  @timespan = 15
  	  @start_time = (time).years.ago.in_time_zone('GMT').at_beginning_of_year
      @end_time = (time).years.ago.in_time_zone('GMT').next_year.at_beginning_of_year
      @days = (@end_time.to_date - @start_time.to_date)/@timespan
  	else
      @timespan = 15
      @start_time = (time).months.ago.in_time_zone('GMT').at_beginning_of_month
      @end_time = (time).months.ago.in_time_zone('GMT').next_month.at_beginning_of_month
      @days = (@end_time.to_date - @start_time.to_date)/@timespan
  	end
  	
  	
  	
  	#loop over each tag that is currently being displayed
  	#get the count at a specific date, then store it in an array with that date
  	#currently uses the latter date of the two for the date on the graph
  	filter_tag.each do |tag_name|
  		
  		@date_array = []
  		
  		for i in 0..(@timespan)
  			@count = Tag.where("name = ? AND created_at >= ? AND created_at <= ?", tag_name.name, (@start_time + (@days*i).days).to_date, (@start_time + (@days*(i+1)).days).to_date).count
  			@date_array << TagCountByDate.new((@start_time.in_time_zone(current_user.time_zone) + (@days*i).days).to_date, @count)
  		end
  		
  		if (tag_name.name.length > 17)
  		  @stat_arrays << Stat_Array.new(tag_name.name.slice(0,15)+"..", @date_array)
  		else
  		  @stat_arrays << Stat_Array.new(tag_name.name, @date_array)
  		end
  		
  	end
  	
  	return @stat_arrays
  	
  	
  end
  

  #based on the params, gets the conditions for the search for the tags
  def get_statistic_conditions(linefilter, listfilter, eventfilter, time, time_units, tagfilter = nil)
  	
  	@array = Array.new
  	@string = ''
  	@array[0] = @string
  	
  	@string = "created_at >= ? AND created_at < ?"
  	
  	
  	
  	#gets the first condition, based on the time of the graph
  	if time_units == 'Week'
  	    @array[1] = ((time+1)).weeks.ago.to_date
  	    @array[2] = (time).weeks.ago.to_date + 2.day
  	elsif time_units == 'Year'
  	    @array[1] = (time).years.ago.to_date.at_beginning_of_year
  	    @array[2] = (time).years.ago.to_date.next_year.at_beginning_of_year
  	else
  	    @array[1] = (time).months.ago.to_date.at_beginning_of_month
  	    @array[2] = (time).months.ago.to_date.next_month.at_beginning_of_month
  	end
  	
  	@string += " AND user_id = ?"
  	@array[@array.size] = current_user.id
  	
  	
  	
  	#filters based on event and list filter
  	
  	if listfilter
  	  @string += " AND item_id = ?"
  	  @array[@array.size] = 0
  	end
  	
  	if eventfilter
  	  @string += " AND event_id = ?"
  	  @array[@array.size] = 0
  	end
  	
  	#filters based on current tag selection
  	if !tagfilter.nil?
  		
	  	@string += " "
  	    
	  	#gets rid of the error where there are empty fields to start with
	  	@first = true
	  	
		for tagname in tagfilter
			
		  if tagname.empty?
		    next
          end
	      
	      if @first
	        @string += "AND ( name = ?"
	        @first = false
	      else
	      	@string += " OR name = ?"
	      end
	      
		  @array[@array.size] = tagname
		end
	  if !@first
       @string += ")"
      end
    end

   
  	
    @array[0] = @string
    return @array
  end
    
end
