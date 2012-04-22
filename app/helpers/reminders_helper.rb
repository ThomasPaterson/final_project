module RemindersHelper
	
  def correct_user_or_poster
    @user = get_effected_user
    @reminders = Reminder.find(params[:id])
    deny_access unless current_user?(@user) or @reminder.poster_id = current_user.id
  end

#sends reminder to all those you added in the creation screen
def send_reminders(invitees, remhash)  
  # create a new pending event for each invitee remindered by the user
  for username in invitees
    if username == current_user.name or username.empty?
      next
    end
      @user_rem = Reminder.new(remhash)
      @user_rem.user_id = User.find_by_name(username).id
      @user_rem.save
  end
	
end


  #gets the reminders for the page based on if the friend filter is on, the search string, and 
  #whose page it is currently
  def get_reminders_from_search(friendfilter, search_string, user)
  	
  	@search_string = '%' + search_string + '%'
  	
    if @user == current_user
	  if friendfilter
	  	  	@reminders = Reminder.joins(:user).where("(users.name LIKE ? OR reminders.name LIKE ? OR reminders.content LIKE ?) AND (reminders.poster_id = ? AND reminders.user_id = ?)", @search_string, @search_string, @search_string, user.id, user.id)

	  else
	  	  	@reminders = Reminder.joins(:user).where("(users.name LIKE ? OR reminders.name LIKE ? OR reminders.content LIKE ?) AND (reminders.poster_id = ? OR reminders.user_id = ?)", @search_string, @search_string, @search_string, user.id, user.id)
	  end
	else
	  	  	@reminders = Reminder.joins(:user).where("(users.name LIKE ? OR reminders.name LIKE ? OR reminders.content LIKE ?) AND (reminders.poster_id = ? AND reminders.user_id = ?)", @search_string, @search_string, @search_string, current_user.id, user.id)
	end  	
  	
  	return @reminders.uniq
  	
  end
  
  
  #if the user is on their own page, get either all ones to self, or all ones sent by or recived by your
  #if on someone else's page, only get the ones for that person sent by you
  def get_reminders(friendfilter, user)

    if @user == current_user
	  if friendfilter
	    return Reminder.where("poster_id = ? AND user_id = ?", user.id, user.id)
	  else
		return  Reminder.where("poster_id = ? OR user_id = ?", user.id, user.id)
	  end
	else
	  return Reminder.where("poster_id = ? AND user_id = ?", current_user.id, user.id)
	end

  end
  
end
